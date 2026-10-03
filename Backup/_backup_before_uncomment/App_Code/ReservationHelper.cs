using System;
using System.Data;
using System.Data.SqlClient;

namespace AirlineReservationSystem
{
    public class PriceBreakdown
    {
        public decimal OnwardBasePerAdult { get; set; }
        public decimal ReturnBasePerAdult { get; set; }
        public decimal CombinedBasePerAdult { get; set; }
        public int AdultCount { get; set; }
        public decimal AdultSubtotal { get; set; }
        public int ChildCount { get; set; }
        public decimal ChildSubtotal { get; set; }
        public int SeniorCount { get; set; }
        public decimal SeniorSubtotal { get; set; }
        public decimal BaseFareTotal { get; set; }
        public decimal AirportTaxesAndFees { get; set; }
        public decimal GrandTotal { get; set; }
    }

    public static class ReservationHelper
    {
        public static DataTable GetCancellationPolicies()
        {
            string query = "SELECT PolicyId, PeriodDescription, RefundPercentage, DeductionPercentage, Remarks FROM CancellationPolicies ORDER BY MinDaysBefore DESC";
            return DbHelper.ExecuteQuery(query);
        }

        public static PriceBreakdown CalculatePricing(
            decimal onwardPrice, 
            decimal returnPrice, 
            string travelClass, 
            int adults, 
            int children, 
            int seniors)
        {
            if (adults < 1) adults = 1;
            if (children < 0) children = 0;
            if (seniors < 0) seniors = 0;

            decimal onwardBase = onwardPrice;
            decimal returnBase = returnPrice;

            decimal perAdult = onwardBase + returnBase;
            decimal adultSub = perAdult * adults;
            
            // Children get 25% discount on base fare
            decimal childSub = (perAdult * 0.75m) * children;

            // Seniors get 15% discount on base fare
            decimal seniorSub = (perAdult * 0.85m) * seniors;

            decimal baseTotal = adultSub + childSub + seniorSub;

            // 5% Airport security & government fuel tax surcharge
            decimal taxes = Math.Round(baseTotal * 0.05m, 2);
            decimal grandTotal = baseTotal + taxes;

            return new PriceBreakdown
            {
                OnwardBasePerAdult = onwardBase,
                ReturnBasePerAdult = returnBase,
                CombinedBasePerAdult = perAdult,
                AdultCount = adults,
                AdultSubtotal = adultSub,
                ChildCount = children,
                ChildSubtotal = childSub,
                SeniorCount = seniors,
                SeniorSubtotal = seniorSub,
                BaseFareTotal = baseTotal,
                AirportTaxesAndFees = taxes,
                GrandTotal = grandTotal
            };
        }

        public static bool CanBlockSeat(DateTime departureTime, out int daysUntilDeparture, out string ruleExplanation)
        {
            daysUntilDeparture = (int)(departureTime.Date - DateTime.Today).TotalDays;
            if (daysUntilDeparture <= 14)
            {
                ruleExplanation = string.Format("Departure is in {0} day(s). Per Airline Rule 1, tickets cannot be blocked within 14 days of departure. Only direct ticket purchase is permitted.", daysUntilDeparture);
                return false;
            }
            else
            {
                ruleExplanation = string.Format("Departure is in {0} days (> 14 days away). Per Airline Rule 2, both Seat Blocking (BLK) and Ticket Purchase (CNF) are available.", daysUntilDeparture);
                return true;
            }
        }

        public static string GenerateBlockingNumber()
        {
            Random random = new Random();
            return "BLK-" + random.Next(10000, 99999).ToString();
        }

        public static string GenerateConfirmationNumber()
        {
            Random random = new Random();
            return "CNF-" + random.Next(10000, 99999).ToString();
        }

        public static bool CreateReservation(
            int userId, 
            int flightId, 
            string passengerName, 
            string seatClass, 
            string actionType, // "Buy" or "Block"
            decimal totalPrice, 
            out string bookingReference, 
            out string errorMessage)
        {
            string status = actionType.Equals("Block", StringComparison.OrdinalIgnoreCase) ? "Blocked" : "Confirmed";
            bookingReference = actionType.Equals("Block", StringComparison.OrdinalIgnoreCase) 
                ? GenerateBlockingNumber() 
                : GenerateConfirmationNumber();
            errorMessage = null;

            try
            {
                using (SqlConnection conn = DbHelper.GetConnection())
                {
                    conn.Open();
                    using (SqlTransaction trans = conn.BeginTransaction())
                    {
                        try
                        {
                            // 1. Insert into Reservations
                            string insertQuery = @"
                                INSERT INTO Reservations (UserId, FlightId, BookingReference, PassengerName, SeatClass, Status, TotalPrice, BookingDate)
                                VALUES (@UserId, @FlightId, @Ref, @Name, @Class, @Status, @Price, GETDATE())";

                            using (SqlCommand cmd = new SqlCommand(insertQuery, conn, trans))
                            {
                                cmd.Parameters.AddWithValue("@UserId", userId);
                                cmd.Parameters.AddWithValue("@FlightId", flightId);
                                cmd.Parameters.AddWithValue("@Ref", bookingReference);
                                cmd.Parameters.AddWithValue("@Name", passengerName);
                                cmd.Parameters.AddWithValue("@Class", seatClass);
                                cmd.Parameters.AddWithValue("@Status", status);
                                cmd.Parameters.AddWithValue("@Price", totalPrice);
                                cmd.ExecuteNonQuery();
                            }

                            // 2. Decrement available seats in Flights
                            string updateSeats = @"UPDATE Flights SET AvailableSeats = AvailableSeats - 1 WHERE FlightId = @FlightId AND AvailableSeats > 0";
                            using (SqlCommand cmd = new SqlCommand(updateSeats, conn, trans))
                            {
                                cmd.Parameters.AddWithValue("@FlightId", flightId);
                                cmd.ExecuteNonQuery();
                            }

                            // 3. Award SkyMiles if confirmed booking (+350 miles)
                            if (status == "Confirmed")
                            {
                                string awardMiles = @"UPDATE Users SET SkyMiles = SkyMiles + 350 WHERE UserId = @UserId";
                                using (SqlCommand cmd = new SqlCommand(awardMiles, conn, trans))
                                {
                                    cmd.Parameters.AddWithValue("@UserId", userId);
                                    cmd.ExecuteNonQuery();
                                }
                            }

                            trans.Commit();
                            return true;
                        }
                        catch (Exception ex)
                        {
                            trans.Rollback();
                            errorMessage = ex.Message;
                            return false;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                errorMessage = ex.Message;
                return false;
            }
        }

        public static BlockedReservationDetails GetBlockedReservationDetails(string bookingRef, out string errorMessage)
        {
            errorMessage = null;
            if (string.IsNullOrWhiteSpace(bookingRef))
            {
                errorMessage = "Please enter a valid Blocking Number.";
                return null;
            }

            try
            {
                string query = @"
                    SELECT r.ReservationId, r.UserId, r.FlightId, r.BookingReference, r.PassengerName, r.SeatClass, r.Status, r.TotalPrice, r.BookingDate,
                           f.FlightNumber, f.AirlineName, f.OriginCity, f.DestinationCity, f.DepartureTime, f.ArrivalTime,
                           u.Username, u.FirstName, u.LastName, u.PreferredCreditCard
                    FROM Reservations r
                    INNER JOIN Flights f ON r.FlightId = f.FlightId
                    INNER JOIN Users u ON r.UserId = u.UserId
                    WHERE UPPER(LTRIM(RTRIM(r.BookingReference))) = UPPER(LTRIM(RTRIM(@Ref)))";

                SqlParameter[] parameters = new SqlParameter[]
                {
                    new SqlParameter("@Ref", bookingRef.Trim())
                };

                DataTable dt = DbHelper.ExecuteQuery(query, parameters);
                if (dt.Rows.Count == 0)
                {
                    errorMessage = string.Format("No reservation found for reference '{0}'. Please verify the number.", bookingRef);
                    return null;
                }

                DataRow row = dt.Rows[0];
                DateTime depTime = Convert.ToDateTime(row["DepartureTime"]);
                int daysUntilDep = (int)(depTime.Date - DateTime.Today).TotalDays;
                string status = row["Status"].ToString();

                BlockedReservationDetails details = new BlockedReservationDetails
                {
                    ReservationId = Convert.ToInt32(row["ReservationId"]),
                    UserId = Convert.ToInt32(row["UserId"]),
                    FlightId = Convert.ToInt32(row["FlightId"]),
                    BookingReference = row["BookingReference"].ToString(),
                    PassengerName = row["PassengerName"].ToString(),
                    SeatClass = row["SeatClass"].ToString(),
                    Status = status,
                    TotalPrice = Convert.ToDecimal(row["TotalPrice"]),
                    BookingDate = Convert.ToDateTime(row["BookingDate"]),
                    FlightNumber = row["FlightNumber"].ToString(),
                    AirlineName = row["AirlineName"].ToString(),
                    OriginCity = row["OriginCity"].ToString(),
                    DestinationCity = row["DestinationCity"].ToString(),
                    DepartureTime = depTime,
                    ArrivalTime = Convert.ToDateTime(row["ArrivalTime"]),
                    Username = row["Username"].ToString(),
                    CustomerFullName = row["FirstName"].ToString() + " " + row["LastName"].ToString(),
                    PreferredCreditCard = row["PreferredCreditCard"] != DBNull.Value ? row["PreferredCreditCard"].ToString() : "",
                    DaysUntilDeparture = daysUntilDep
                };

                // Check 2-week rule & status
                if (!status.Equals("Blocked", StringComparison.OrdinalIgnoreCase))
                {
                    details.IsEligibleForConfirmation = false;
                    details.ValidityStatusMessage = string.Format("This reservation is currently '{0}'. Only reservations with 'Blocked' status can be confirmed.", status);
                }
                else if (daysUntilDep < 14)
                {
                    details.IsEligibleForConfirmation = false;
                    details.ValidityStatusMessage = string.Format("Departure is in {0} day(s) ({1:dd-MMM-yyyy}). Per airline rule, blocked tickets must be confirmed at least 2 weeks (14 days) before departure. This reservation has expired and cannot be confirmed.", daysUntilDep, depTime);
                }
                else
                {
                    details.IsEligibleForConfirmation = true;
                    details.ValidityStatusMessage = string.Format("Valid for confirmation: Flight departs in {0} days ({1:dd-MMM-yyyy}), satisfying the 2-week advance confirmation rule.", daysUntilDep, depTime);
                }

                return details;
            }
            catch (Exception ex)
            {
                errorMessage = ex.Message;
                return null;
            }
        }

        public static bool ConfirmBlockedReservation(
            int reservationId,
            int userId,
            string oldBlockingRef,
            string paymentCard,
            out string newConfirmationNumber,
            out string errorMessage)
        {
            newConfirmationNumber = GenerateConfirmationNumber();
            errorMessage = null;

            try
            {
                using (SqlConnection conn = DbHelper.GetConnection())
                {
                    conn.Open();
                    using (SqlTransaction trans = conn.BeginTransaction())
                    {
                        try
                        {
                            // 1. Update Reservation to Confirmed and set new CNF reference
                            string updateRes = @"
                                UPDATE Reservations 
                                SET BookingReference = @NewCNF, Status = 'Confirmed'
                                WHERE ReservationId = @ReservationId AND Status = 'Blocked'";

                            using (SqlCommand cmd = new SqlCommand(updateRes, conn, trans))
                            {
                                cmd.Parameters.AddWithValue("@NewCNF", newConfirmationNumber);
                                cmd.Parameters.AddWithValue("@ReservationId", reservationId);
                                int affected = cmd.ExecuteNonQuery();
                                if (affected == 0)
                                {
                                    throw new Exception("Reservation was not in Blocked status or could not be found.");
                                }
                            }

                            // 2. Award SkyMiles (+350 miles)
                            string awardMiles = @"UPDATE Users SET SkyMiles = SkyMiles + 350 WHERE UserId = @UserId";
                            using (SqlCommand cmd = new SqlCommand(awardMiles, conn, trans))
                            {
                                cmd.Parameters.AddWithValue("@UserId", userId);
                                cmd.ExecuteNonQuery();
                            }

                            // 3. If credit card was updated/provided
                            if (!string.IsNullOrWhiteSpace(paymentCard))
                            {
                                string updateCard = @"UPDATE Users SET PreferredCreditCard = @Card WHERE UserId = @UserId AND (PreferredCreditCard IS NULL OR PreferredCreditCard = '')";
                                using (SqlCommand cmd = new SqlCommand(updateCard, conn, trans))
                                {
                                    cmd.Parameters.AddWithValue("@Card", paymentCard);
                                    cmd.Parameters.AddWithValue("@UserId", userId);
                                    cmd.ExecuteNonQuery();
                                }
                            }

                            trans.Commit();
                            return true;
                        }
                        catch (Exception ex)
                        {
                            trans.Rollback();
                            errorMessage = ex.Message;
                            return false;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                errorMessage = ex.Message;
                return false;
            }
        }

        public static bool CancelExpiredBlock(int reservationId, int flightId, out string errorMessage)
        {
            errorMessage = null;
            try
            {
                using (SqlConnection conn = DbHelper.GetConnection())
                {
                    conn.Open();
                    using (SqlTransaction trans = conn.BeginTransaction())
                    {
                        try
                        {
                            // 1. Update status to Cancelled
                            string updateRes = "UPDATE Reservations SET Status = 'Cancelled' WHERE ReservationId = @ReservationId AND Status = 'Blocked'";
                            using (SqlCommand cmd = new SqlCommand(updateRes, conn, trans))
                            {
                                cmd.Parameters.AddWithValue("@ReservationId", reservationId);
                                int affected = cmd.ExecuteNonQuery();
                                if (affected == 0)
                                {
                                    throw new Exception("Reservation is not in Blocked status.");
                                }
                            }

                            // 2. Return seat back to Flights inventory
                            string updateSeats = "UPDATE Flights SET AvailableSeats = AvailableSeats + 1 WHERE FlightId = @FlightId";
                            using (SqlCommand cmd = new SqlCommand(updateSeats, conn, trans))
                            {
                                cmd.Parameters.AddWithValue("@FlightId", flightId);
                                cmd.ExecuteNonQuery();
                            }

                            trans.Commit();
                            return true;
                        }
                        catch (Exception ex)
                        {
                            trans.Rollback();
                            errorMessage = ex.Message;
                            return false;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                errorMessage = ex.Message;
                return false;
            }
        }

        public static RescheduleTicketDetails GetTicketForReschedule(string confirmationNumber, out string errorMessage)
        {
            errorMessage = null;
            if (string.IsNullOrWhiteSpace(confirmationNumber))
            {
                errorMessage = "Please enter a valid Confirmation Number (CNF-XXXXX).";
                return null;
            }

            try
            {
                string query = @"
                    SELECT r.ReservationId, r.UserId, r.FlightId, r.BookingReference, r.PassengerName, r.SeatClass, r.Status, r.TotalPrice, r.BookingDate,
                           f.FlightNumber, f.AirlineName, f.OriginCity, f.DestinationCity, f.DepartureTime, f.ArrivalTime
                    FROM Reservations r
                    INNER JOIN Flights f ON r.FlightId = f.FlightId
                    WHERE UPPER(LTRIM(RTRIM(r.BookingReference))) = UPPER(LTRIM(RTRIM(@Ref)))";

                SqlParameter[] parameters = new SqlParameter[]
                {
                    new SqlParameter("@Ref", confirmationNumber.Trim())
                };

                DataTable dt = DbHelper.ExecuteQuery(query, parameters);
                if (dt.Rows.Count == 0)
                {
                    errorMessage = string.Format("No reservation found for reference '{0}'.", confirmationNumber);
                    return null;
                }

                DataRow row = dt.Rows[0];
                string status = row["Status"].ToString();
                RescheduleTicketDetails details = new RescheduleTicketDetails
                {
                    ReservationId = Convert.ToInt32(row["ReservationId"]),
                    UserId = Convert.ToInt32(row["UserId"]),
                    FlightId = Convert.ToInt32(row["FlightId"]),
                    BookingReference = row["BookingReference"].ToString(),
                    PassengerName = row["PassengerName"].ToString(),
                    SeatClass = row["SeatClass"].ToString(),
                    Status = status,
                    TotalPrice = Convert.ToDecimal(row["TotalPrice"]),
                    BookingDate = Convert.ToDateTime(row["BookingDate"]),
                    FlightNumber = row["FlightNumber"].ToString(),
                    AirlineName = row["AirlineName"].ToString(),
                    OriginCity = row["OriginCity"].ToString(),
                    DestinationCity = row["DestinationCity"].ToString(),
                    DepartureTime = Convert.ToDateTime(row["DepartureTime"]),
                    ArrivalTime = Convert.ToDateTime(row["ArrivalTime"])
                };

                // RULE: "Sirf confirmed tickets reschedule ho sakti hain. Blocked ticket reschedule nahi hoga."
                if (status.Equals("Blocked", StringComparison.OrdinalIgnoreCase))
                {
                    details.IsEligibleForReschedule = false;
                    details.IneligibilityReason = "Blocked tickets (BLK-XXXXX) cannot be rescheduled. Per airline policy, you must first confirm and pay for your blocked ticket before requesting a reschedule.";
                }
                else if (status.Equals("Cancelled", StringComparison.OrdinalIgnoreCase))
                {
                    details.IsEligibleForReschedule = false;
                    details.IneligibilityReason = "Cancelled reservations cannot be rescheduled.";
                }
                else if (!status.Equals("Confirmed", StringComparison.OrdinalIgnoreCase))
                {
                    details.IsEligibleForReschedule = false;
                    details.IneligibilityReason = string.Format("Reservation with status '{0}' is not eligible for reschedule.", status);
                }
                else
                {
                    details.IsEligibleForReschedule = true;
                }

                return details;
            }
            catch (Exception ex)
            {
                errorMessage = ex.Message;
                return null;
            }
        }

        public static DataTable GetAlternateFlightsForReschedule(string originCity, string destinationCity, DateTime newDepartureDate, int excludeFlightId, string seatClass)
        {
            DataTable dt = FlightSearchHelper.SearchDirectFlights(originCity, destinationCity, newDepartureDate);
            if (dt == null || dt.Rows.Count == 0)
            {
                dt = FlightSearchHelper.SearchDirectFlights(originCity, destinationCity, null);
            }

            if (dt != null)
            {
                if (!dt.Columns.Contains("ApplicablePrice"))
                    dt.Columns.Add("ApplicablePrice", typeof(decimal));
                if (!dt.Columns.Contains("DurationFormatted"))
                    dt.Columns.Add("DurationFormatted", typeof(string));

                for (int i = dt.Rows.Count - 1; i >= 0; i--)
                {
                    DataRow r = dt.Rows[i];
                    int fid = Convert.ToInt32(r["FlightId"]);
                    if (fid == excludeFlightId)
                    {
                        dt.Rows.RemoveAt(i);
                        continue;
                    }

                    decimal price = 0;
                    if (seatClass.Equals("Business", StringComparison.OrdinalIgnoreCase))
                        price = Convert.ToDecimal(r["BusinessPrice"]);
                    else if (seatClass.Equals("First", StringComparison.OrdinalIgnoreCase))
                        price = Convert.ToDecimal(r["FirstClassPrice"]);
                    else
                        price = Convert.ToDecimal(r["EconomyPrice"]);

                    r["ApplicablePrice"] = price;

                    DateTime dep = Convert.ToDateTime(r["DepartureTime"]);
                    DateTime arr = Convert.ToDateTime(r["ArrivalTime"]);
                    TimeSpan duration = arr - dep;
                    r["DurationFormatted"] = string.Format("{0}h {1}m", (int)duration.TotalHours, duration.Minutes);
                }
            }

            return dt;
        }

        public static RescheduleResult ExecuteReschedule(
            int reservationId,
            int userId,
            string oldConfirmationNumber,
            int oldFlightId,
            int newFlightId,
            decimal oldPrice,
            decimal newPrice,
            int passengers = 1)
        {
            RescheduleResult result = new RescheduleResult
            {
                OldConfirmationNumber = oldConfirmationNumber,
                OldFlightId = oldFlightId,
                NewFlightId = newFlightId,
                OldPrice = oldPrice,
                NewPrice = newPrice,
                PriceDifference = newPrice - oldPrice
            };

            // Calculate price adjustment
            if (result.PriceDifference > 0)
            {
                result.PriceAdjustmentType = "ExtraCharge";
                result.PriceAdjustmentDescription = string.Format("New Price is higher by PKR {0:N2} (Extra Charge Processed).", result.PriceDifference);
            }
            else if (result.PriceDifference < 0)
            {
                result.PriceAdjustmentType = "RefundCredit";
                result.PriceAdjustmentDescription = string.Format("New Price is lower by PKR {0:N2} (Refund / Credit Issued to Card/Miles).", Math.Abs(result.PriceDifference));
            }
            else
            {
                result.PriceAdjustmentType = "EvenExchange";
                result.PriceAdjustmentDescription = "Even exchange (PKR 0.00 difference). No charge or refund required.";
            }

            // Generate new confirmation number per requirement
            string newCnf = GenerateConfirmationNumber();
            result.NewConfirmationNumber = newCnf;

            try
            {
                using (SqlConnection conn = DbHelper.GetConnection())
                {
                    conn.Open();
                    using (SqlTransaction trans = conn.BeginTransaction())
                    {
                        try
                        {
                            // 1. Old flight seats + passengers
                            string restoreSeatsQuery = "UPDATE Flights SET AvailableSeats = AvailableSeats + @Count WHERE FlightId = @OldFlightId";
                            using (SqlCommand cmd = new SqlCommand(restoreSeatsQuery, conn, trans))
                            {
                                cmd.Parameters.AddWithValue("@Count", passengers);
                                cmd.Parameters.AddWithValue("@OldFlightId", oldFlightId);
                                cmd.ExecuteNonQuery();
                            }

                            // 2. New flight seats - passengers
                            string deductSeatsQuery = "UPDATE Flights SET AvailableSeats = AvailableSeats - @Count WHERE FlightId = @NewFlightId AND AvailableSeats >= @Count";
                            using (SqlCommand cmd = new SqlCommand(deductSeatsQuery, conn, trans))
                            {
                                cmd.Parameters.AddWithValue("@Count", passengers);
                                cmd.Parameters.AddWithValue("@NewFlightId", newFlightId);
                                int affected = cmd.ExecuteNonQuery();
                                if (affected == 0)
                                {
                                    throw new Exception("Selected new flight does not have enough available seats.");
                                }
                            }

                            // 3. Update Reservation: New FlightId, New Confirmation Number, New TotalPrice, BookingDate
                            string updateResQuery = @"
                                UPDATE Reservations
                                SET FlightId = @NewFlightId,
                                    BookingReference = @NewCNF,
                                    TotalPrice = @NewPrice,
                                    BookingDate = GETDATE()
                                WHERE ReservationId = @ReservationId AND Status = 'Confirmed'";
                            using (SqlCommand cmd = new SqlCommand(updateResQuery, conn, trans))
                            {
                                cmd.Parameters.AddWithValue("@NewFlightId", newFlightId);
                                cmd.Parameters.AddWithValue("@NewCNF", newCnf);
                                cmd.Parameters.AddWithValue("@NewPrice", newPrice);
                                cmd.Parameters.AddWithValue("@ReservationId", reservationId);
                                int resAffected = cmd.ExecuteNonQuery();
                                if (resAffected == 0)
                                {
                                    throw new Exception("Reservation was not found or is not in Confirmed status.");
                                }
                            }

                            trans.Commit();
                            result.Success = true;
                            return result;
                        }
                        catch (Exception ex)
                        {
                            trans.Rollback();
                            result.Success = false;
                            result.ErrorMessage = ex.Message;
                            return result;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                result.Success = false;
                result.ErrorMessage = ex.Message;
                return result;
            }
        }

        public static string GenerateCancellationNumber()
        {
            Random random = new Random();
            return "CAN-" + random.Next(10000, 99999).ToString();
        }

        public static CancellationTicketDetails GetTicketForCancellation(string reference, out string errorMessage)
        {
            errorMessage = null;
            if (string.IsNullOrWhiteSpace(reference))
            {
                errorMessage = "Please enter a valid Reference Number (BLK-XXXXX or CNF-XXXXX).";
                return null;
            }

            try
            {
                string query = @"
                    SELECT r.ReservationId, r.UserId, r.FlightId, r.BookingReference, r.PassengerName, r.SeatClass, r.Status, r.TotalPrice, r.BookingDate,
                           f.FlightNumber, f.AirlineName, f.OriginCity, f.DestinationCity, f.DepartureTime, f.ArrivalTime,
                           u.Username, u.FirstName, u.LastName, u.SkyMiles
                    FROM Reservations r
                    INNER JOIN Flights f ON r.FlightId = f.FlightId
                    INNER JOIN Users u ON r.UserId = u.UserId
                    WHERE UPPER(LTRIM(RTRIM(r.BookingReference))) = UPPER(LTRIM(RTRIM(@Ref)))";

                SqlParameter[] parameters = new SqlParameter[]
                {
                    new SqlParameter("@Ref", reference.Trim())
                };

                DataTable dt = DbHelper.ExecuteQuery(query, parameters);
                if (dt.Rows.Count == 0)
                {
                    errorMessage = string.Format("No reservation found for reference '{0}'. Please verify and try again.", reference);
                    return null;
                }

                DataRow row = dt.Rows[0];
                string status = row["Status"].ToString();
                DateTime depTime = Convert.ToDateTime(row["DepartureTime"]);
                int daysUntilDep = (int)(depTime.Date - DateTime.Today).TotalDays;
                decimal totalPrice = Convert.ToDecimal(row["TotalPrice"]);
                int currentSkyMiles = Convert.ToInt32(row["SkyMiles"]);

                CancellationTicketDetails details = new CancellationTicketDetails
                {
                    ReservationId = Convert.ToInt32(row["ReservationId"]),
                    UserId = Convert.ToInt32(row["UserId"]),
                    FlightId = Convert.ToInt32(row["FlightId"]),
                    BookingReference = row["BookingReference"].ToString(),
                    PassengerName = row["PassengerName"].ToString(),
                    SeatClass = row["SeatClass"].ToString(),
                    Status = status,
                    TotalPrice = totalPrice,
                    BookingDate = Convert.ToDateTime(row["BookingDate"]),
                    FlightNumber = row["FlightNumber"].ToString(),
                    AirlineName = row["AirlineName"].ToString(),
                    OriginCity = row["OriginCity"].ToString(),
                    DestinationCity = row["DestinationCity"].ToString(),
                    DepartureTime = depTime,
                    ArrivalTime = Convert.ToDateTime(row["ArrivalTime"]),
                    CustomerUsername = row["Username"].ToString(),
                    CustomerFullName = row["FirstName"].ToString() + " " + row["LastName"].ToString(),
                    CurrentSkyMiles = currentSkyMiles,
                    DaysUntilDeparture = daysUntilDep
                };

                if (status.Equals("Cancelled", StringComparison.OrdinalIgnoreCase))
                {
                    details.IsEligibleForCancellation = false;
                    details.IneligibilityReason = "This reservation has already been cancelled.";
                    return details;
                }

                if (status.Equals("Blocked", StringComparison.OrdinalIgnoreCase))
                {
                    details.IsBlockedTicket = true;
                    details.IsConfirmedTicket = false;
                    details.IsEligibleForCancellation = true;
                    details.PolicyBracket = "Blocked Reservation (No payment was charged, seat will be returned to inventory).";
                    details.RefundPercentage = 0;
                    details.DeductionPercentage = 0;
                    details.RefundAmount = 0m;
                    details.CancellationFee = 0m;
                    details.SkyMilesToDeduct = 0;
                }
                else if (status.Equals("Confirmed", StringComparison.OrdinalIgnoreCase))
                {
                    details.IsBlockedTicket = false;
                    details.IsConfirmedTicket = true;
                    details.IsEligibleForCancellation = true;
                    details.SkyMilesToDeduct = 350;

                    // Compute policy refund based on days remaining before departure:
                    // 30+ days: 90% refund, 10% deduction
                    // 15–30 days: 70% refund, 30% deduction
                    // Less than 15 days (1-14): 40% refund, 60% deduction
                    // < 1 day (0 or past): 0% refund, 100% deduction
                    if (daysUntilDep >= 30)
                    {
                        details.RefundPercentage = 90;
                        details.DeductionPercentage = 10;
                        details.PolicyBracket = "30+ days before departure (90% Refund / 10% Cancellation Fee)";
                    }
                    else if (daysUntilDep >= 15)
                    {
                        details.RefundPercentage = 70;
                        details.DeductionPercentage = 30;
                        details.PolicyBracket = "15 to 30 days before departure (70% Refund / 30% Cancellation Fee)";
                    }
                    else if (daysUntilDep >= 1)
                    {
                        details.RefundPercentage = 40;
                        details.DeductionPercentage = 60;
                        details.PolicyBracket = "Less than 15 days before departure (40% Refund / 60% Cancellation Fee)";
                    }
                    else
                    {
                        details.RefundPercentage = 0;
                        details.DeductionPercentage = 100;
                        details.PolicyBracket = "Within 24 hours of departure / Departed (0% Refund - Non-Refundable)";
                    }

                    details.RefundAmount = Math.Round(totalPrice * (details.RefundPercentage / 100.0m), 2);
                    details.CancellationFee = totalPrice - details.RefundAmount;
                }
                else
                {
                    details.IsEligibleForCancellation = false;
                    details.IneligibilityReason = string.Format("Reservation with status '{0}' cannot be cancelled.", status);
                }

                return details;
            }
            catch (Exception ex)
            {
                errorMessage = ex.Message;
                return null;
            }
        }

        public static CancellationResult ExecuteCancellation(
            int reservationId,
            int userId,
            int flightId,
            string oldReference,
            string ticketType,
            decimal refundAmount,
            int skyMilesToDeduct)
        {
            CancellationResult result = new CancellationResult
            {
                OldReference = oldReference,
                TicketType = ticketType,
                RefundAmount = refundAmount,
                SkyMilesDeducted = skyMilesToDeduct
            };

            string cancellationNumber = GenerateCancellationNumber();
            result.CancellationNumber = cancellationNumber;

            try
            {
                using (SqlConnection conn = DbHelper.GetConnection())
                {
                    conn.Open();
                    using (SqlTransaction trans = conn.BeginTransaction())
                    {
                        try
                        {
                            // 1. Update Reservation status to Cancelled and update BookingReference to CAN-XXXXX
                            string updateResQuery = @"
                                UPDATE Reservations
                                SET Status = 'Cancelled',
                                    BookingReference = @CancellationNumber
                                WHERE ReservationId = @ReservationId AND Status IN ('Blocked', 'Confirmed')";

                            using (SqlCommand cmd = new SqlCommand(updateResQuery, conn, trans))
                            {
                                cmd.Parameters.AddWithValue("@CancellationNumber", cancellationNumber);
                                cmd.Parameters.AddWithValue("@ReservationId", reservationId);
                                int affected = cmd.ExecuteNonQuery();
                                if (affected == 0)
                                {
                                    throw new Exception("Reservation could not be found or has already been processed.");
                                }
                            }

                            // 2. Restore Seat to Flight Inventory (+1 Available Seat)
                            string restoreSeatsQuery = "UPDATE Flights SET AvailableSeats = AvailableSeats + 1 WHERE FlightId = @FlightId";
                            using (SqlCommand cmd = new SqlCommand(restoreSeatsQuery, conn, trans))
                            {
                                cmd.Parameters.AddWithValue("@FlightId", flightId);
                                cmd.ExecuteNonQuery();
                            }
                            result.SeatsRestored = 1;

                            // 3. Deduct SkyMiles if Confirmed ticket
                            if (ticketType.Equals("Confirmed", StringComparison.OrdinalIgnoreCase) && skyMilesToDeduct > 0)
                            {
                                string deductMilesQuery = @"
                                    UPDATE Users 
                                    SET SkyMiles = CASE WHEN SkyMiles >= @Miles THEN SkyMiles - @Miles ELSE 0 END 
                                    WHERE UserId = @UserId";
                                using (SqlCommand cmd = new SqlCommand(deductMilesQuery, conn, trans))
                                {
                                    cmd.Parameters.AddWithValue("@Miles", skyMilesToDeduct);
                                    cmd.Parameters.AddWithValue("@UserId", userId);
                                    cmd.ExecuteNonQuery();
                                }
                            }

                            trans.Commit();
                            result.Success = true;
                            return result;
                        }
                        catch (Exception ex)
                        {
                            trans.Rollback();
                            result.Success = false;
                            result.ErrorMessage = ex.Message;
                            return result;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                result.Success = false;
                result.ErrorMessage = ex.Message;
                return result;
            }
        }

        public static TicketStatusDetails GetTicketStatus(string reference, out string errorMessage)
        {
            errorMessage = null;
            if (string.IsNullOrWhiteSpace(reference))
            {
                errorMessage = "Please enter a valid Booking Reference Number (BLK-XXXXX or CNF-XXXXX).";
                return null;
            }

            try
            {
                string query = @"
                    SELECT r.ReservationId, r.UserId, r.FlightId, r.BookingReference, r.PassengerName, r.SeatClass, 
                           r.Status AS TicketStatus, r.TotalPrice, r.BookingDate,
                           f.FlightNumber, f.AirlineName, f.OriginCity, f.DestinationCity, f.DepartureTime, f.ArrivalTime, 
                           f.Status AS FlightStatus, f.RevisedDepartureTime, f.RevisedArrivalTime, f.TimingChangeReason,
                           u.Username, u.FirstName, u.LastName, u.Email, u.PhoneNumber
                    FROM Reservations r
                    INNER JOIN Flights f ON r.FlightId = f.FlightId
                    LEFT JOIN Users u ON r.UserId = u.UserId
                    WHERE UPPER(LTRIM(RTRIM(r.BookingReference))) = UPPER(LTRIM(RTRIM(@Ref)))";

                SqlParameter[] parameters = new SqlParameter[]
                {
                    new SqlParameter("@Ref", reference.Trim())
                };

                DataTable dt = DbHelper.ExecuteQuery(query, parameters);
                if (dt.Rows.Count == 0)
                {
                    errorMessage = string.Format("No ticket found with reference '{0}'. Please verify the number and try again.", reference);
                    return null;
                }

                DataRow row = dt.Rows[0];
                DateTime depTime = Convert.ToDateTime(row["DepartureTime"]);
                DateTime arrTime = Convert.ToDateTime(row["ArrivalTime"]);

                DateTime? revisedDep = null;
                if (row["RevisedDepartureTime"] != DBNull.Value && row["RevisedDepartureTime"] != null)
                {
                    revisedDep = Convert.ToDateTime(row["RevisedDepartureTime"]);
                }

                DateTime? revisedArr = null;
                if (row["RevisedArrivalTime"] != DBNull.Value && row["RevisedArrivalTime"] != null)
                {
                    revisedArr = Convert.ToDateTime(row["RevisedArrivalTime"]);
                }

                string timingReason = row["TimingChangeReason"] != DBNull.Value ? row["TimingChangeReason"].ToString() : "";
                string flightStatus = row["FlightStatus"] != DBNull.Value ? row["FlightStatus"].ToString() : "Scheduled";

                bool hasTimingChange = false;
                string diffFormatted = "";

                if (revisedDep.HasValue && revisedDep.Value != depTime)
                {
                    hasTimingChange = true;
                    TimeSpan diff = revisedDep.Value - depTime;
                    if (diff.TotalMinutes > 0)
                    {
                        diffFormatted = string.Format("+{0}h {1}m Delayed", (int)diff.TotalHours, Math.Abs(diff.Minutes));
                    }
                    else if (diff.TotalMinutes < 0)
                    {
                        diffFormatted = string.Format("{0}h {1}m Advanced / Earlier", (int)Math.Abs(diff.TotalHours), Math.Abs(diff.Minutes));
                    }
                }
                else if (flightStatus.Equals("Delayed", StringComparison.OrdinalIgnoreCase) || 
                         flightStatus.Equals("Timing Changed", StringComparison.OrdinalIgnoreCase) ||
                         flightStatus.Equals("Rescheduled", StringComparison.OrdinalIgnoreCase))
                {
                    hasTimingChange = true;
                    diffFormatted = "Flight schedule revised per airline dispatch notice";
                }

                TicketStatusDetails details = new TicketStatusDetails
                {
                    ReservationId = Convert.ToInt32(row["ReservationId"]),
                    UserId = row["UserId"] != DBNull.Value ? Convert.ToInt32(row["UserId"]) : 0,
                    FlightId = Convert.ToInt32(row["FlightId"]),
                    BookingReference = row["BookingReference"].ToString(),
                    PassengerName = row["PassengerName"].ToString(),
                    SeatClass = row["SeatClass"].ToString(),
                    TicketStatus = row["TicketStatus"].ToString(),
                    TotalPrice = Convert.ToDecimal(row["TotalPrice"]),
                    BookingDate = Convert.ToDateTime(row["BookingDate"]),
                    FlightNumber = row["FlightNumber"].ToString(),
                    AirlineName = row["AirlineName"].ToString(),
                    OriginCity = row["OriginCity"].ToString(),
                    DestinationCity = row["DestinationCity"].ToString(),
                    DepartureTime = depTime,
                    ArrivalTime = arrTime,
                    RevisedDepartureTime = revisedDep,
                    RevisedArrivalTime = revisedArr,
                    TimingChangeReason = timingReason,
                    FlightStatus = flightStatus,
                    HasTimingChange = hasTimingChange,
                    TimingDifferenceFormatted = diffFormatted,
                    DepartureDateFormatted = depTime.ToString("ddd, dd-MMM-yyyy"),
                    ArrivalDateFormatted = arrTime.ToString("ddd, dd-MMM-yyyy"),
                    DepartureTimeFormatted = depTime.ToString("hh:mm tt"),
                    ArrivalTimeFormatted = arrTime.ToString("hh:mm tt"),
                    RevisedDepartureDateFormatted = revisedDep.HasValue ? revisedDep.Value.ToString("ddd, dd-MMM-yyyy") : "",
                    RevisedDepartureTimeFormatted = revisedDep.HasValue ? revisedDep.Value.ToString("hh:mm tt") : "",
                    RevisedArrivalDateFormatted = revisedArr.HasValue ? revisedArr.Value.ToString("ddd, dd-MMM-yyyy") : "",
                    RevisedArrivalTimeFormatted = revisedArr.HasValue ? revisedArr.Value.ToString("hh:mm tt") : "",
                    CustomerUsername = row["Username"] != DBNull.Value ? row["Username"].ToString() : "",
                    CustomerFullName = row["FirstName"] != DBNull.Value ? row["FirstName"].ToString() + " " + row["LastName"].ToString() : ""
                };

                return details;
            }
            catch (Exception ex)
            {
                errorMessage = ex.Message;
                return null;
            }
        }
    }

    public class BlockedReservationDetails
    {
        public int ReservationId { get; set; }
        public int UserId { get; set; }
        public int FlightId { get; set; }
        public string BookingReference { get; set; }
        public string PassengerName { get; set; }
        public string SeatClass { get; set; }
        public string Status { get; set; }
        public decimal TotalPrice { get; set; }
        public DateTime BookingDate { get; set; }
        public string FlightNumber { get; set; }
        public string AirlineName { get; set; }
        public string OriginCity { get; set; }
        public string DestinationCity { get; set; }
        public DateTime DepartureTime { get; set; }
        public DateTime ArrivalTime { get; set; }
        public string Username { get; set; }
        public string CustomerFullName { get; set; }
        public string PreferredCreditCard { get; set; }
        public int DaysUntilDeparture { get; set; }
        public bool IsEligibleForConfirmation { get; set; }
        public string ValidityStatusMessage { get; set; }
    }

    public class RescheduleTicketDetails
    {
        public int ReservationId { get; set; }
        public int UserId { get; set; }
        public int FlightId { get; set; }
        public string BookingReference { get; set; }
        public string PassengerName { get; set; }
        public string SeatClass { get; set; }
        public string Status { get; set; }
        public decimal TotalPrice { get; set; }
        public DateTime BookingDate { get; set; }
        public string FlightNumber { get; set; }
        public string AirlineName { get; set; }
        public string OriginCity { get; set; }
        public string DestinationCity { get; set; }
        public DateTime DepartureTime { get; set; }
        public DateTime ArrivalTime { get; set; }
        public bool IsEligibleForReschedule { get; set; }
        public string IneligibilityReason { get; set; }
    }

    public class RescheduleResult
    {
        public bool Success { get; set; }
        public string OldConfirmationNumber { get; set; }
        public string NewConfirmationNumber { get; set; }
        public int OldFlightId { get; set; }
        public int NewFlightId { get; set; }
        public decimal OldPrice { get; set; }
        public decimal NewPrice { get; set; }
        public decimal PriceDifference { get; set; }
        public string PriceAdjustmentType { get; set; }
        public string PriceAdjustmentDescription { get; set; }
        public string ErrorMessage { get; set; }
    }

    public class CancellationTicketDetails
    {
        public int ReservationId { get; set; }
        public int UserId { get; set; }
        public int FlightId { get; set; }
        public string BookingReference { get; set; }
        public string PassengerName { get; set; }
        public string SeatClass { get; set; }
        public string Status { get; set; }
        public decimal TotalPrice { get; set; }
        public DateTime BookingDate { get; set; }
        public string FlightNumber { get; set; }
        public string AirlineName { get; set; }
        public string OriginCity { get; set; }
        public string DestinationCity { get; set; }
        public DateTime DepartureTime { get; set; }
        public DateTime ArrivalTime { get; set; }
        public string CustomerUsername { get; set; }
        public string CustomerFullName { get; set; }
        public int CurrentSkyMiles { get; set; }
        public int DaysUntilDeparture { get; set; }
        public bool IsBlockedTicket { get; set; }
        public bool IsConfirmedTicket { get; set; }
        public bool IsEligibleForCancellation { get; set; }
        public string IneligibilityReason { get; set; }
        public string PolicyBracket { get; set; }
        public int RefundPercentage { get; set; }
        public int DeductionPercentage { get; set; }
        public decimal RefundAmount { get; set; }
        public decimal CancellationFee { get; set; }
        public int SkyMilesToDeduct { get; set; }
    }

    public class CancellationResult
    {
        public bool Success { get; set; }
        public string CancellationNumber { get; set; }
        public string OldReference { get; set; }
        public string TicketType { get; set; }
        public int SeatsRestored { get; set; }
        public decimal RefundAmount { get; set; }
        public int SkyMilesDeducted { get; set; }
        public string ErrorMessage { get; set; }
    }

    public class TicketStatusDetails
    {
        public int ReservationId { get; set; }
        public int UserId { get; set; }
        public int FlightId { get; set; }
        public string BookingReference { get; set; }
        public string PassengerName { get; set; }
        public string SeatClass { get; set; }
        public string TicketStatus { get; set; }
        public decimal TotalPrice { get; set; }
        public DateTime BookingDate { get; set; }
        public string FlightNumber { get; set; }
        public string AirlineName { get; set; }
        public string OriginCity { get; set; }
        public string DestinationCity { get; set; }
        public DateTime DepartureTime { get; set; }
        public DateTime ArrivalTime { get; set; }
        public DateTime? RevisedDepartureTime { get; set; }
        public DateTime? RevisedArrivalTime { get; set; }
        public string TimingChangeReason { get; set; }
        public string FlightStatus { get; set; }
        public bool HasTimingChange { get; set; }
        public string TimingDifferenceFormatted { get; set; }
        public string DepartureDateFormatted { get; set; }
        public string ArrivalDateFormatted { get; set; }
        public string DepartureTimeFormatted { get; set; }
        public string ArrivalTimeFormatted { get; set; }
        public string RevisedDepartureDateFormatted { get; set; }
        public string RevisedDepartureTimeFormatted { get; set; }
        public string RevisedArrivalDateFormatted { get; set; }
        public string RevisedArrivalTimeFormatted { get; set; }
        public string CustomerUsername { get; set; }
        public string CustomerFullName { get; set; }
    }
}
