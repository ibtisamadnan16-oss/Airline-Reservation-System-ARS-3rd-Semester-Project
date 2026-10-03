using System;
using System.Data;
using System.Data.SqlClient;

namespace AirlineReservationSystem
{
    public class AdminDashboardStats
    {
        public int TotalFlights { get; set; }
        public int TotalReservations { get; set; }
        public int ConfirmedBookings { get; set; }
        public int BlockedBookings { get; set; }
        public int CancelledBookings { get; set; }
        public int TotalUsers { get; set; }
        public decimal TotalRevenue { get; set; }
        public int TotalAvailableSeats { get; set; }
        public int TotalCapacity { get; set; }
        public double SeatOccupancyRate { get; set; }
    }

    public static class AdminHelper
    {
        public static AdminDashboardStats GetDashboardStats()
        {
            AdminDashboardStats stats = new AdminDashboardStats();

            try
            {
                string flightQuery = @"
                    SELECT
                        COUNT(FlightId) AS TotalFlights,
                        ISNULL(SUM(AvailableSeats), 0) AS TotalAvail,
                        ISNULL(SUM(TotalSeats), 0) AS TotalCap
                    FROM Flights";
                DataTable dtF = DbHelper.ExecuteQuery(flightQuery);
                if (dtF.Rows.Count > 0)
                {
                    stats.TotalFlights = Convert.ToInt32(dtF.Rows[0]["TotalFlights"]);
                    stats.TotalAvailableSeats = Convert.ToInt32(dtF.Rows[0]["TotalAvail"]);
                    stats.TotalCapacity = Convert.ToInt32(dtF.Rows[0]["TotalCap"]);
                    if (stats.TotalCapacity > 0)
                    {
                        int booked = stats.TotalCapacity - stats.TotalAvailableSeats;
                        stats.SeatOccupancyRate = Math.Round(((double)booked / stats.TotalCapacity) * 100.0, 1);
                    }
                }

                string resQuery = @"
                    SELECT
                        COUNT(ReservationId) AS TotalRes,
                        ISNULL(SUM(CASE WHEN Status = 'Confirmed' THEN 1 ELSE 0 END), 0) AS ConfirmedCount,
                        ISNULL(SUM(CASE WHEN Status = 'Blocked' THEN 1 ELSE 0 END), 0) AS BlockedCount,
                        ISNULL(SUM(CASE WHEN Status = 'Cancelled' THEN 1 ELSE 0 END), 0) AS CancelledCount,
                        ISNULL(SUM(CASE WHEN Status = 'Confirmed' THEN TotalPrice ELSE 0 END), 0) AS Revenue
                    FROM Reservations";
                DataTable dtR = DbHelper.ExecuteQuery(resQuery);
                if (dtR.Rows.Count > 0)
                {
                    stats.TotalReservations = Convert.ToInt32(dtR.Rows[0]["TotalRes"]);
                    stats.ConfirmedBookings = Convert.ToInt32(dtR.Rows[0]["ConfirmedCount"]);
                    stats.BlockedBookings = Convert.ToInt32(dtR.Rows[0]["BlockedCount"]);
                    stats.CancelledBookings = Convert.ToInt32(dtR.Rows[0]["CancelledCount"]);
                    stats.TotalRevenue = Convert.ToDecimal(dtR.Rows[0]["Revenue"]);
                }

                string userQuery = "SELECT COUNT(UserId) FROM Users";
                object userCountObj = DbHelper.ExecuteScalar(userQuery);
                stats.TotalUsers = userCountObj != null && userCountObj != DBNull.Value ? Convert.ToInt32(userCountObj) : 0;
            }
            catch
            {
            }

            return stats;
        }

        public static DataTable GetAllFlights()
        {
            string query = @"
                SELECT FlightId, FlightNumber, AirlineName, OriginCity, DestinationCity,
                       DepartureTime, ArrivalTime, EconomyPrice, BusinessPrice, FirstClassPrice,
                       TotalSeats, AvailableSeats, Status, RevisedDepartureTime, RevisedArrivalTime, TimingChangeReason
                FROM Flights
                ORDER BY DepartureTime ASC";
            return DbHelper.ExecuteQuery(query);
        }

        public static DataRow GetFlightById(int flightId)
        {
            string query = "SELECT * FROM Flights WHERE FlightId = @Id";
            DataTable dt = DbHelper.ExecuteQuery(query, new SqlParameter[] { new SqlParameter("@Id", flightId) });
            return dt.Rows.Count > 0 ? dt.Rows[0] : null;
        }

        public static bool SaveFlight(int? flightId, string flightNo, string airline, string origin, string dest,
            DateTime depTime, DateTime arrTime, decimal econ, decimal bus, decimal first,
            int totalSeats, int availableSeats, string status, out string errorMessage)
        {
            errorMessage = null;
            try
            {
                if (string.IsNullOrWhiteSpace(flightNo) || string.IsNullOrWhiteSpace(origin) || string.IsNullOrWhiteSpace(dest))
                {
                    errorMessage = "Flight number, Origin, and Destination are required.";
                    return false;
                }

                if (arrTime <= depTime)
                {
                    errorMessage = "Arrival Time must be after Departure Time.";
                    return false;
                }

                if (availableSeats > totalSeats)
                {
                    errorMessage = "Available Seats cannot exceed Total Aircraft Capacity.";
                    return false;
                }

                if (flightId.HasValue && flightId.Value > 0)
                {
                    string query = @"
                        UPDATE Flights
                        SET FlightNumber = @FNo,
                            AirlineName = @Airline,
                            OriginCity = @Origin,
                            DestinationCity = @Dest,
                            DepartureTime = @Dep,
                            ArrivalTime = @Arr,
                            EconomyPrice = @Econ,
                            BusinessPrice = @Bus,
                            FirstClassPrice = @First,
                            TotalSeats = @TotSeats,
                            AvailableSeats = @AvailSeats,
                            Status = @Status
                        WHERE FlightId = @Id";

                    SqlParameter[] p = new SqlParameter[]
                    {
                        new SqlParameter("@FNo", flightNo.Trim().ToUpper()),
                        new SqlParameter("@Airline", airline.Trim()),
                        new SqlParameter("@Origin", origin.Trim()),
                        new SqlParameter("@Dest", dest.Trim()),
                        new SqlParameter("@Dep", depTime),
                        new SqlParameter("@Arr", arrTime),
                        new SqlParameter("@Econ", econ),
                        new SqlParameter("@Bus", bus),
                        new SqlParameter("@First", first),
                        new SqlParameter("@TotSeats", totalSeats),
                        new SqlParameter("@AvailSeats", availableSeats),
                        new SqlParameter("@Status", status.Trim()),
                        new SqlParameter("@Id", flightId.Value)
                    };
                    return DbHelper.ExecuteNonQuery(query, p) > 0;
                }
                else
                {
                    string query = @"
                        INSERT INTO Flights
                        (FlightNumber, AirlineName, OriginCity, DestinationCity, DepartureTime, ArrivalTime,
                         EconomyPrice, BusinessPrice, FirstClassPrice, TotalSeats, AvailableSeats, Status)
                        VALUES
                        (@FNo, @Airline, @Origin, @Dest, @Dep, @Arr, @Econ, @Bus, @First, @TotSeats, @AvailSeats, @Status)";

                    SqlParameter[] p = new SqlParameter[]
                    {
                        new SqlParameter("@FNo", flightNo.Trim().ToUpper()),
                        new SqlParameter("@Airline", airline.Trim()),
                        new SqlParameter("@Origin", origin.Trim()),
                        new SqlParameter("@Dest", dest.Trim()),
                        new SqlParameter("@Dep", depTime),
                        new SqlParameter("@Arr", arrTime),
                        new SqlParameter("@Econ", econ),
                        new SqlParameter("@Bus", bus),
                        new SqlParameter("@First", first),
                        new SqlParameter("@TotSeats", totalSeats),
                        new SqlParameter("@AvailSeats", availableSeats),
                        new SqlParameter("@Status", status.Trim())
                    };
                    return DbHelper.ExecuteNonQuery(query, p) > 0;
                }
            }
            catch (Exception ex)
            {
                errorMessage = ex.Message;
                return false;
            }
        }

        public static bool DeleteFlight(int flightId, out string errorMessage)
        {
            errorMessage = null;
            try
            {
                string checkQuery = "SELECT COUNT(*) FROM Reservations WHERE FlightId = @Id";
                int bookingsCount = Convert.ToInt32(DbHelper.ExecuteScalar(checkQuery, new SqlParameter[] { new SqlParameter("@Id", flightId) }));
                if (bookingsCount > 0)
                {
                    errorMessage = string.Format("Cannot delete flight #{0} because there are {1} passenger reservation(s) associated with it. Please cancel or reassign the bookings first.", flightId, bookingsCount);
                    return false;
                }

                string deleteQuery = "DELETE FROM Flights WHERE FlightId = @Id";
                return DbHelper.ExecuteNonQuery(deleteQuery, new SqlParameter[] { new SqlParameter("@Id", flightId) }) > 0;
            }
            catch (Exception ex)
            {
                errorMessage = ex.Message;
                return false;
            }
        }

        public static bool UpdateFlightSchedule(int flightId, DateTime depTime, DateTime arrTime,
            DateTime? revisedDep, DateTime? revisedArr, string status, string timingReason, out string errorMessage)
        {
            errorMessage = null;
            try
            {
                string query = @"
                    UPDATE Flights
                    SET DepartureTime = @Dep,
                        ArrivalTime = @Arr,
                        RevisedDepartureTime = @RevDep,
                        RevisedArrivalTime = @RevArr,
                        Status = @Status,
                        TimingChangeReason = @Reason
                    WHERE FlightId = @Id";

                SqlParameter[] p = new SqlParameter[]
                {
                    new SqlParameter("@Dep", depTime),
                    new SqlParameter("@Arr", arrTime),
                    new SqlParameter("@RevDep", (object)revisedDep ?? DBNull.Value),
                    new SqlParameter("@RevArr", (object)revisedArr ?? DBNull.Value),
                    new SqlParameter("@Status", status.Trim()),
                    new SqlParameter("@Reason", string.IsNullOrWhiteSpace(timingReason) ? (object)DBNull.Value : timingReason.Trim()),
                    new SqlParameter("@Id", flightId)
                };

                return DbHelper.ExecuteNonQuery(query, p) > 0;
            }
            catch (Exception ex)
            {
                errorMessage = ex.Message;
                return false;
            }
        }

        public static DataTable GetAllReservations(string statusFilter, string searchKeyword)
        {
            string query = @"
                SELECT b.ReservationId, b.BookingReference, b.PassengerName, b.SeatClass, b.TotalPrice,
                       b.BookingDate, b.Status,
                       u.Username AS CustomerUsername, u.Email AS CustomerEmail,
                       f.FlightNumber, f.AirlineName, f.OriginCity, f.DestinationCity,
                       f.DepartureTime, f.ArrivalTime
                FROM Reservations b
                LEFT JOIN Users u ON b.UserId = u.UserId
                LEFT JOIN Flights f ON b.FlightId = f.FlightId
                WHERE 1=1 ";

            if (!string.IsNullOrWhiteSpace(statusFilter) && statusFilter != "All")
            {
                query += " AND b.Status = @StatusFilter ";
            }

            if (!string.IsNullOrWhiteSpace(searchKeyword))
            {
                query += " AND (b.BookingReference LIKE @Search OR b.PassengerName LIKE @Search OR u.Username LIKE @Search OR f.FlightNumber LIKE @Search) ";
            }

            query += " ORDER BY b.BookingDate DESC";

            System.Collections.Generic.List<SqlParameter> pList = new System.Collections.Generic.List<SqlParameter>();
            if (!string.IsNullOrWhiteSpace(statusFilter) && statusFilter != "All")
            {
                pList.Add(new SqlParameter("@StatusFilter", statusFilter));
            }
            if (!string.IsNullOrWhiteSpace(searchKeyword))
            {
                pList.Add(new SqlParameter("@Search", "%" + searchKeyword.Trim() + "%"));
            }

            return DbHelper.ExecuteQuery(query, pList.ToArray());
        }

        public static bool AdminUpdateBookingStatus(int reservationId, string newStatus, out string errorMessage)
        {
            errorMessage = null;
            try
            {
                string selQuery = "SELECT Status, FlightId FROM Reservations WHERE ReservationId = @Id";
                DataTable dt = DbHelper.ExecuteQuery(selQuery, new SqlParameter[] { new SqlParameter("@Id", reservationId) });
                if (dt.Rows.Count == 0)
                {
                    errorMessage = "Reservation record not found.";
                    return false;
                }

                string currentStatus = dt.Rows[0]["Status"].ToString();
                int flightId = Convert.ToInt32(dt.Rows[0]["FlightId"]);

                string updQuery = "UPDATE Reservations SET Status = @NewStatus WHERE ReservationId = @Id";
                int rows = DbHelper.ExecuteNonQuery(updQuery, new SqlParameter[]
                {
                    new SqlParameter("@NewStatus", newStatus),
                    new SqlParameter("@Id", reservationId)
                });

                if (rows > 0)
                {
                    if (newStatus.Equals("Cancelled", StringComparison.OrdinalIgnoreCase) &&
                        !currentStatus.Equals("Cancelled", StringComparison.OrdinalIgnoreCase))
                    {
                        DbHelper.ExecuteNonQuery("UPDATE Flights SET AvailableSeats = AvailableSeats + 1 WHERE FlightId = @FId",
                            new SqlParameter[] { new SqlParameter("@FId", flightId) });
                    }
                    else if (currentStatus.Equals("Cancelled", StringComparison.OrdinalIgnoreCase) &&
                            (newStatus.Equals("Confirmed", StringComparison.OrdinalIgnoreCase) || newStatus.Equals("Blocked", StringComparison.OrdinalIgnoreCase)))
                    {
                        DbHelper.ExecuteNonQuery("UPDATE Flights SET AvailableSeats = CASE WHEN AvailableSeats > 0 THEN AvailableSeats - 1 ELSE 0 END WHERE FlightId = @FId",
                            new SqlParameter[] { new SqlParameter("@FId", flightId) });
                    }
                    return true;
                }
                return false;
            }
            catch (Exception ex)
            {
                errorMessage = ex.Message;
                return false;
            }
        }

        public static DataTable GetAllUsers(string searchKeyword)
        {
            string query = @"
                SELECT UserId, Username, FirstName, LastName, Email, PhoneNumber,
                       Gender, Age, Address, PreferredCreditCard, SkyMiles, Role, CreatedAt
                FROM Users
                WHERE 1=1 ";

            if (!string.IsNullOrWhiteSpace(searchKeyword))
            {
                query += " AND (Username LIKE @Search OR Email LIKE @Search OR FirstName LIKE @Search OR LastName LIKE @Search) ";
            }

            query += " ORDER BY UserId ASC";

            SqlParameter[] p = null;
            if (!string.IsNullOrWhiteSpace(searchKeyword))
            {
                p = new SqlParameter[] { new SqlParameter("@Search", "%" + searchKeyword.Trim() + "%") };
            }

            return DbHelper.ExecuteQuery(query, p);
        }

        public static bool UpdateUserRole(int userId, string newRole, out string errorMessage)
        {
            errorMessage = null;
            try
            {
                string query = "UPDATE Users SET Role = @Role WHERE UserId = @Id";
                SqlParameter[] p = new SqlParameter[]
                {
                    new SqlParameter("@Role", newRole.Trim()),
                    new SqlParameter("@Id", userId)
                };
                return DbHelper.ExecuteNonQuery(query, p) > 0;
            }
            catch (Exception ex)
            {
                errorMessage = ex.Message;
                return false;
            }
        }

        public static bool UpdateUserSkyMiles(int userId, int newMiles, out string errorMessage)
        {
            errorMessage = null;
            try
            {
                if (newMiles < 0)
                {
                    errorMessage = "SkyMiles cannot be negative.";
                    return false;
                }
                string query = "UPDATE Users SET SkyMiles = @Miles WHERE UserId = @Id";
                SqlParameter[] p = new SqlParameter[]
                {
                    new SqlParameter("@Miles", newMiles),
                    new SqlParameter("@Id", userId)
                };
                return DbHelper.ExecuteNonQuery(query, p) > 0;
            }
            catch (Exception ex)
            {
                errorMessage = ex.Message;
                return false;
            }
        }

        public static DataTable GetSeatAvailabilityOverview()
        {
            string query = @"
                SELECT
                    f.FlightId, f.FlightNumber, f.AirlineName, f.OriginCity, f.DestinationCity,
                    f.DepartureTime, f.TotalSeats, f.AvailableSeats,
                    (f.TotalSeats - f.AvailableSeats) AS BookedSeats,
                    ROUND(CAST((f.TotalSeats - f.AvailableSeats) AS FLOAT) / CAST(f.TotalSeats AS FLOAT) * 100, 1) AS OccupancyPercentage,
                    f.Status
                FROM Flights f
                ORDER BY f.DepartureTime ASC";
            return DbHelper.ExecuteQuery(query);
        }

        public static bool UpdateSeatInventory(int flightId, int newAvailableSeats, out string errorMessage)
        {
            errorMessage = null;
            try
            {
                string queryTot = "SELECT TotalSeats FROM Flights WHERE FlightId = @Id";
                object totObj = DbHelper.ExecuteScalar(queryTot, new SqlParameter[] { new SqlParameter("@Id", flightId) });
                if (totObj == null)
                {
                    errorMessage = "Flight not found.";
                    return false;
                }
                int totalSeats = Convert.ToInt32(totObj);
                if (newAvailableSeats < 0 || newAvailableSeats > totalSeats)
                {
                    errorMessage = string.Format("Available seats must be between 0 and total aircraft capacity ({0}).", totalSeats);
                    return false;
                }

                string query = "UPDATE Flights SET AvailableSeats = @Avail WHERE FlightId = @Id";
                return DbHelper.ExecuteNonQuery(query, new SqlParameter[]
                {
                    new SqlParameter("@Avail", newAvailableSeats),
                    new SqlParameter("@Id", flightId)
                }) > 0;
            }
            catch (Exception ex)
            {
                errorMessage = ex.Message;
                return false;
            }
        }
    }
}
