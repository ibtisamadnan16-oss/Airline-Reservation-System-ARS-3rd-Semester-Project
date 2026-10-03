using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace AirlineReservationSystem
{
    public class CityInfo
    {
        public int CityId { get; set; }
        public string CityName { get; set; }
        public string QualifiedName { get; set; }
        public string Country { get; set; }
        public string AirportCode { get; set; }
        public string AirportName { get; set; }
        public bool IsDirectlyServiced { get; set; }
        public string NearestServicedCity { get; set; }
        public string NearestAirportCode { get; set; }
        public int DistanceToNearestKm { get; set; }
    }

    public class ConnectingFlightRoute
    {
        public DataRow Leg1 { get; set; }
        public DataRow Leg2 { get; set; }
        public string TransferCity { get; set; }
        public TimeSpan LayoverDuration { get; set; }
        public decimal TotalEconomyPrice { get; set; }
        public decimal TotalBusinessPrice { get; set; }
        public int MinAvailableSeats { get; set; }
    }

    public static class FlightSearchHelper
    {
        public static List<CityInfo> LookupCity(string cityName)
        {
            List<CityInfo> list = new List<CityInfo>();
            if (string.IsNullOrWhiteSpace(cityName)) return list;

            string query = @"
                SELECT CityId, CityName, QualifiedName, Country, StateOrProvince, AirportCode,
                       AirportName, IsDirectlyServiced, NearestServicedCity, NearestAirportCode, DistanceToNearestKm
                FROM Cities
                WHERE CityName = @Name OR QualifiedName LIKE @LikeName OR AirportCode = @Code";

            SqlParameter[] parameters = new SqlParameter[]
            {
                new SqlParameter("@Name", cityName.Trim()),
                new SqlParameter("@LikeName", "%" + cityName.Trim() + "%"),
                new SqlParameter("@Code", cityName.Trim().ToUpper())
            };

            DataTable dt = DbHelper.ExecuteQuery(query, parameters);
            foreach (DataRow r in dt.Rows)
            {
                list.Add(new CityInfo
                {
                    CityId = Convert.ToInt32(r["CityId"]),
                    CityName = r["CityName"].ToString(),
                    QualifiedName = r["QualifiedName"].ToString(),
                    Country = r["Country"].ToString(),
                    AirportCode = r["AirportCode"].ToString(),
                    AirportName = r["AirportName"].ToString(),
                    IsDirectlyServiced = Convert.ToBoolean(r["IsDirectlyServiced"]),
                    NearestServicedCity = r["NearestServicedCity"] != DBNull.Value ? r["NearestServicedCity"].ToString() : null,
                    NearestAirportCode = r["NearestAirportCode"] != DBNull.Value ? r["NearestAirportCode"].ToString() : null,
                    DistanceToNearestKm = r["DistanceToNearestKm"] != DBNull.Value ? Convert.ToInt32(r["DistanceToNearestKm"]) : 0
                });
            }
            return list;
        }

        public static DataTable SearchDirectFlights(string originCity, string destinationCity, DateTime? departureDate = null)
        {
            string query = @"
                SELECT FlightId, FlightNumber, AirlineName, OriginCity, DestinationCity,
                       DepartureTime, ArrivalTime, EconomyPrice, BusinessPrice, FirstClassPrice,
                       TotalSeats, AvailableSeats, Status
                FROM Flights
                WHERE AvailableSeats > 0
                  AND (OriginCity = @Origin OR OriginCity LIKE @OriginLike)
                  AND (DestinationCity = @Dest OR DestinationCity LIKE @DestLike)";

            List<SqlParameter> parameters = new List<SqlParameter>
            {
                new SqlParameter("@Origin", originCity),
                new SqlParameter("@OriginLike", "%" + originCity + "%"),
                new SqlParameter("@Dest", destinationCity),
                new SqlParameter("@DestLike", "%" + destinationCity + "%")
            };

            if (departureDate.HasValue)
            {
                query += " AND CAST(DepartureTime AS DATE) = @DepDate";
                parameters.Add(new SqlParameter("@DepDate", departureDate.Value.Date));
            }

            query += " ORDER BY DepartureTime ASC";

            return DbHelper.ExecuteQuery(query, parameters.ToArray());
        }

        public static List<ConnectingFlightRoute> FindConnectingRoutes(string originCity, string destinationCity, DateTime? departureDate = null)
        {
            List<ConnectingFlightRoute> routes = new List<ConnectingFlightRoute>();

            string leg1Query = @"
                SELECT FlightId, FlightNumber, AirlineName, OriginCity, DestinationCity,
                       DepartureTime, ArrivalTime, EconomyPrice, BusinessPrice, FirstClassPrice, AvailableSeats
                FROM Flights
                WHERE AvailableSeats > 0
                  AND (OriginCity = @Origin OR OriginCity LIKE @OriginLike)";

            List<SqlParameter> p1 = new List<SqlParameter>
            {
                new SqlParameter("@Origin", originCity),
                new SqlParameter("@OriginLike", "%" + originCity + "%")
            };

            if (departureDate.HasValue)
            {
                leg1Query += " AND CAST(DepartureTime AS DATE) = @DepDate";
                p1.Add(new SqlParameter("@DepDate", departureDate.Value.Date));
            }

            DataTable dtLeg1 = DbHelper.ExecuteQuery(leg1Query, p1.ToArray());

            foreach (DataRow r1 in dtLeg1.Rows)
            {
                string transferCity = r1["DestinationCity"].ToString();
                DateTime arrival1 = Convert.ToDateTime(r1["ArrivalTime"]);

                string leg2Query = @"
                    SELECT FlightId, FlightNumber, AirlineName, OriginCity, DestinationCity,
                           DepartureTime, ArrivalTime, EconomyPrice, BusinessPrice, FirstClassPrice, AvailableSeats
                    FROM Flights
                    WHERE AvailableSeats > 0
                      AND OriginCity = @TransferCity
                      AND (DestinationCity = @Dest OR DestinationCity LIKE @DestLike)
                      AND DepartureTime >= @MinDepTime
                      AND DepartureTime <= @MaxDepTime
                    ORDER BY DepartureTime ASC";

                SqlParameter[] p2 = new SqlParameter[]
                {
                    new SqlParameter("@TransferCity", transferCity),
                    new SqlParameter("@Dest", destinationCity),
                    new SqlParameter("@DestLike", "%" + destinationCity + "%"),
                    new SqlParameter("@MinDepTime", arrival1.AddHours(1)),
                    new SqlParameter("@MaxDepTime", arrival1.AddHours(24))
                };

                DataTable dtLeg2 = DbHelper.ExecuteQuery(leg2Query, p2);
                foreach (DataRow r2 in dtLeg2.Rows)
                {
                    DateTime dep2 = Convert.ToDateTime(r2["DepartureTime"]);
                    TimeSpan layover = dep2 - arrival1;

                    decimal econ = Convert.ToDecimal(r1["EconomyPrice"]) + Convert.ToDecimal(r2["EconomyPrice"]);
                    decimal bus = Convert.ToDecimal(r1["BusinessPrice"]) + Convert.ToDecimal(r2["BusinessPrice"]);
                    int seats = Math.Min(Convert.ToInt32(r1["AvailableSeats"]), Convert.ToInt32(r2["AvailableSeats"]));

                    routes.Add(new ConnectingFlightRoute
                    {
                        Leg1 = r1,
                        Leg2 = r2,
                        TransferCity = transferCity,
                        LayoverDuration = layover,
                        TotalEconomyPrice = econ,
                        TotalBusinessPrice = bus,
                        MinAvailableSeats = seats
                    });
                }
            }

            return routes;
        }

        public static bool ValidateDates(DateTime depDate, bool isRoundTrip, DateTime? retDate, out string errorMessage)
        {
            DateTime today = DateTime.Today;

            if (depDate.Date < today)
            {
                errorMessage = "Departure Date cannot be in the past. Please select today or a future date.";
                return false;
            }

            if (isRoundTrip)
            {
                if (!retDate.HasValue)
                {
                    errorMessage = "Return Date is required for a Round-Trip journey.";
                    return false;
                }

                if (retDate.Value.Date < depDate.Date)
                {
                    errorMessage = "Invalid Date Range: Return Date cannot be earlier than Departure Date.";
                    return false;
                }
            }

            errorMessage = null;
            return true;
        }

        public static PublicFlightDetails GetPublicFlightDetails(string flightNumber, DateTime? flightDate, out string errorMessage)
        {
            errorMessage = null;
            if (string.IsNullOrWhiteSpace(flightNumber))
            {
                errorMessage = "Please enter a valid Flight Number (e.g. PK-301, PK-302, EK-007, TK-708).";
                return null;
            }

            string cleanFlightNo = flightNumber.Trim().Replace(" ", "");

            try
            {
                string query;
                SqlParameter[] parameters;

                if (flightDate.HasValue)
                {
                    query = @"
                        SELECT TOP 1 FlightId, FlightNumber, AirlineName, OriginCity, DestinationCity,
                               DepartureTime, ArrivalTime, EconomyPrice, BusinessPrice, FirstClassPrice,
                               TotalSeats, AvailableSeats, Status, RevisedDepartureTime, RevisedArrivalTime, TimingChangeReason
                        FROM Flights
                        WHERE (REPLACE(UPPER(LTRIM(RTRIM(FlightNumber))), ' ', '') = UPPER(@FNo)
                            OR REPLACE(UPPER(LTRIM(RTRIM(FlightNumber))), '-', '') = REPLACE(UPPER(@FNo), '-', ''))
                          AND CAST(DepartureTime AS DATE) = CAST(@Date AS DATE)
                        ORDER BY DepartureTime ASC";

                    parameters = new SqlParameter[]
                    {
                        new SqlParameter("@FNo", cleanFlightNo),
                        new SqlParameter("@Date", flightDate.Value.Date)
                    };
                }
                else
                {
                    query = @"
                        SELECT TOP 1 FlightId, FlightNumber, AirlineName, OriginCity, DestinationCity,
                               DepartureTime, ArrivalTime, EconomyPrice, BusinessPrice, FirstClassPrice,
                               TotalSeats, AvailableSeats, Status, RevisedDepartureTime, RevisedArrivalTime, TimingChangeReason
                        FROM Flights
                        WHERE REPLACE(UPPER(LTRIM(RTRIM(FlightNumber))), ' ', '') = UPPER(@FNo)
                           OR REPLACE(UPPER(LTRIM(RTRIM(FlightNumber))), '-', '') = REPLACE(UPPER(@FNo), '-', '')
                        ORDER BY
                            CASE WHEN DepartureTime >= CAST(GETDATE() AS DATE) THEN 0 ELSE 1 END,
                            ABS(DATEDIFF(minute, DepartureTime, GETDATE())) ASC";

                    parameters = new SqlParameter[]
                    {
                        new SqlParameter("@FNo", cleanFlightNo)
                    };
                }

                DataTable dt = DbHelper.ExecuteQuery(query, parameters);
                if (dt.Rows.Count == 0)
                {
                    if (flightDate.HasValue)
                    {
                        errorMessage = string.Format("No flight found for '{0}' on {1:dd-MMM-yyyy}. Please check the flight number or select another date.", flightNumber, flightDate.Value);
                    }
                    else
                    {
                        errorMessage = string.Format("No flight schedule found matching flight number '{0}'.", flightNumber);
                    }
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
                string flightStatus = row["Status"] != DBNull.Value ? row["Status"].ToString() : "Scheduled";

                bool hasTimingChange = false;
                string diffFormatted = "";

                if (revisedDep.HasValue && revisedDep.Value != depTime)
                {
                    hasTimingChange = true;
                    TimeSpan diff = revisedDep.Value - depTime;
                    if (diff.TotalMinutes > 0)
                        diffFormatted = string.Format("+{0}h {1}m Delayed", (int)diff.TotalHours, Math.Abs(diff.Minutes));
                    else if (diff.TotalMinutes < 0)
                        diffFormatted = string.Format("{0}h {1}m Earlier / Advanced", (int)Math.Abs(diff.TotalHours), Math.Abs(diff.Minutes));
                }
                else if (flightStatus.Equals("Delayed", StringComparison.OrdinalIgnoreCase) ||
                         flightStatus.Equals("Timing Changed", StringComparison.OrdinalIgnoreCase) ||
                         flightStatus.Equals("Rescheduled", StringComparison.OrdinalIgnoreCase))
                {
                    hasTimingChange = true;
                    diffFormatted = "Flight timing adjusted per airline dispatch notice";
                }

                TimeSpan duration = arrTime >= depTime ? (arrTime - depTime) : (depTime - arrTime);
                string durFormatted = string.Format("{0}h {1}m", (int)duration.TotalHours, Math.Abs(duration.Minutes));

                PublicFlightDetails details = new PublicFlightDetails
                {
                    FlightId = Convert.ToInt32(row["FlightId"]),
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
                    EconomyPrice = Convert.ToDecimal(row["EconomyPrice"]),
                    BusinessPrice = Convert.ToDecimal(row["BusinessPrice"]),
                    FirstClassPrice = Convert.ToDecimal(row["FirstClassPrice"]),
                    TotalSeats = Convert.ToInt32(row["TotalSeats"]),
                    AvailableSeats = Convert.ToInt32(row["AvailableSeats"]),
                    HasTimingChange = hasTimingChange,
                    TimingDifferenceFormatted = diffFormatted,
                    DurationFormatted = durFormatted,
                    DepartureDateFormatted = depTime.ToString("ddd, dd-MMM-yyyy"),
                    DepartureTimeFormatted = depTime.ToString("hh:mm tt"),
                    ArrivalDateFormatted = arrTime.ToString("ddd, dd-MMM-yyyy"),
                    ArrivalTimeFormatted = arrTime.ToString("hh:mm tt"),
                    RevisedDepartureDateFormatted = revisedDep.HasValue ? revisedDep.Value.ToString("ddd, dd-MMM-yyyy") : "",
                    RevisedDepartureTimeFormatted = revisedDep.HasValue ? revisedDep.Value.ToString("hh:mm tt") : "",
                    RevisedArrivalDateFormatted = revisedArr.HasValue ? revisedArr.Value.ToString("ddd, dd-MMM-yyyy") : "",
                    RevisedArrivalTimeFormatted = revisedArr.HasValue ? revisedArr.Value.ToString("hh:mm tt") : ""
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

    public class PublicFlightDetails
    {
        public int FlightId { get; set; }
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
        public decimal EconomyPrice { get; set; }
        public decimal BusinessPrice { get; set; }
        public decimal FirstClassPrice { get; set; }
        public int TotalSeats { get; set; }
        public int AvailableSeats { get; set; }
        public bool HasTimingChange { get; set; }
        public string TimingDifferenceFormatted { get; set; }
        public string DurationFormatted { get; set; }
        public string DepartureDateFormatted { get; set; }
        public string DepartureTimeFormatted { get; set; }
        public string ArrivalDateFormatted { get; set; }
        public string ArrivalTimeFormatted { get; set; }
        public string RevisedDepartureDateFormatted { get; set; }
        public string RevisedDepartureTimeFormatted { get; set; }
        public string RevisedArrivalDateFormatted { get; set; }
        public string RevisedArrivalTimeFormatted { get; set; }
    }
}
