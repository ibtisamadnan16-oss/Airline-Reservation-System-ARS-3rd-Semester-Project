using System;
using System.Web.UI;
using AirlineReservationSystem;

public partial class Public_FlightDetails : Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            string qFlight = Request.QueryString["flight"];
            string qDate = Request.QueryString["date"];

            if (!string.IsNullOrWhiteSpace(qFlight))
            {
                txtFlightNumber.Text = qFlight.Trim();

                DateTime parsedDate;
                if (!string.IsNullOrWhiteSpace(qDate) && DateTime.TryParse(qDate, out parsedDate))
                {
                    txtFlightDate.Text = parsedDate.ToString("yyyy-MM-dd");
                    ExecuteFlightLookup(qFlight.Trim(), parsedDate);
                }
                else
                {
                    ExecuteFlightLookup(qFlight.Trim(), null);
                }
            }
        }
        else
        {
            // Support form submissions and direct POST
            string flightNo = Request.Form["ctl00$MainContent$txtFlightNumber"];
            string dateStr = Request.Form["ctl00$MainContent$txtFlightDate"];

            if (!string.IsNullOrWhiteSpace(flightNo))
            {
                txtFlightNumber.Text = flightNo.Trim();
                DateTime? dateVal = null;
                DateTime parsed;
                if (!string.IsNullOrWhiteSpace(dateStr) && DateTime.TryParse(dateStr, out parsed))
                {
                    txtFlightDate.Text = parsed.ToString("yyyy-MM-dd");
                    dateVal = parsed;
                }
                ExecuteFlightLookup(flightNo.Trim(), dateVal);
            }
        }
    }

    protected void btnSearchFlight_Click(object sender, EventArgs e)
    {
        string flightNo = txtFlightNumber.Text.Trim();
        if (string.IsNullOrWhiteSpace(flightNo))
        {
            ShowAlert("Please enter a valid Flight Number (e.g. PK-301, PK-302, EK-007, TK-708).", "warning");
            return;
        }

        DateTime? dateVal = null;
        DateTime parsedDate;
        if (!string.IsNullOrWhiteSpace(txtFlightDate.Text) && DateTime.TryParse(txtFlightDate.Text, out parsedDate))
        {
            dateVal = parsedDate;
        }

        ExecuteFlightLookup(flightNo, dateVal);
    }

    private void ExecuteFlightLookup(string flightNumber, DateTime? flightDate)
    {
        pnlAlert.Visible = false;
        pnlFlightResults.Visible = false;

        string errorMessage;
        PublicFlightDetails details = FlightSearchHelper.GetPublicFlightDetails(flightNumber, flightDate, out errorMessage);

        if (details == null)
        {
            ShowAlert(errorMessage ?? string.Format("No flight schedule found matching flight number '{0}'.", flightNumber), "danger");
            return;
        }

        pnlFlightResults.Visible = true;

        // Basic Header Info
        litFlightNumber.Text = Server.HtmlEncode(details.FlightNumber);
        litAirlineName.Text = Server.HtmlEncode(details.AirlineName);
        litFlightDuration.Text = details.DurationFormatted;

        // Origin and Destination
        litOriginCity.Text = Server.HtmlEncode(details.OriginCity);
        litDestinationCity.Text = Server.HtmlEncode(details.DestinationCity);

        // Required Phase 12 Outputs: Departure Time and Arrival Time
        litDepartureTime.Text = details.DepartureTimeFormatted;
        litDepartureDate.Text = details.DepartureDateFormatted;
        litArrivalTime.Text = details.ArrivalTimeFormatted;
        litArrivalDate.Text = details.ArrivalDateFormatted;

        // Handling timing revisions / delays
        if (details.HasTimingChange)
        {
            pnlDelayAdvisory.Visible = true;
            litTimingDifferenceBadge.Text = !string.IsNullOrEmpty(details.TimingDifferenceFormatted) 
                ? details.TimingDifferenceFormatted 
                : "Schedule Revised";
            litTimingReason.Text = !string.IsNullOrEmpty(details.TimingChangeReason) 
                ? Server.HtmlEncode(details.TimingChangeReason) 
                : "Operations dispatch timing adjustment.";

            // Show revised departure box
            pnlNormalDeparture.Visible = false;
            pnlRevisedDeparture.Visible = true;
            litOriginalDepTime.Text = details.DepartureTimeFormatted;
            litRevisedDepTime.Text = details.RevisedDepartureTimeFormatted;
            litRevisedDepDate.Text = !string.IsNullOrEmpty(details.RevisedDepartureDateFormatted) 
                ? details.RevisedDepartureDateFormatted 
                : details.DepartureDateFormatted;

            // Show revised arrival box
            pnlNormalArrival.Visible = false;
            pnlRevisedArrival.Visible = true;
            litOriginalArrTime.Text = details.ArrivalTimeFormatted;
            litRevisedArrTime.Text = details.RevisedArrivalTimeFormatted;
            litRevisedArrDate.Text = !string.IsNullOrEmpty(details.RevisedArrivalDateFormatted) 
                ? details.RevisedArrivalDateFormatted 
                : details.ArrivalDateFormatted;

            litStatusBadge.Text = "<span class='status-badge-delayed'><i class='fa-solid fa-clock-rotate-left me-1'></i> Delayed / Rescheduled</span>";
        }
        else
        {
            pnlDelayAdvisory.Visible = false;
            pnlNormalDeparture.Visible = true;
            pnlRevisedDeparture.Visible = false;
            pnlNormalArrival.Visible = true;
            pnlRevisedArrival.Visible = false;

            litStatusBadge.Text = "<span class='status-badge-ontime'><i class='fa-solid fa-circle-check me-1'></i> On-Time &bull; Scheduled</span>";
        }

        // Seats & Fares
        litAvailableSeats.Text = details.AvailableSeats.ToString();
        litTotalSeats.Text = details.TotalSeats.ToString();
        litEconomyPrice.Text = details.EconomyPrice.ToString("N0");
        litBusinessPrice.Text = details.BusinessPrice.ToString("N0");
        litFirstClassPrice.Text = details.FirstClassPrice.ToString("N0");

        // Dynamic Action Links (Guest vs Logged-In User)
        if (UserStateHelper.IsLoggedIn)
        {
            litActionButtons.Text = string.Format(
                "<a href='SearchFlights.aspx?origin={0}&destination={1}' class='btn btn-success fw-bold'><i class='fa-solid fa-ticket me-1'></i> Book This Flight</a>",
                Server.UrlEncode(details.OriginCity),
                Server.UrlEncode(details.DestinationCity));
        }
        else
        {
            litActionButtons.Text = string.Format(
                "<a href='Login.aspx' class='btn btn-warning text-dark fw-bold'><i class='fa-solid fa-right-to-bracket me-1'></i> Login to Book</a> " +
                "<a href='SearchFlights.aspx' class='btn btn-outline-primary'><i class='fa-solid fa-magnifying-glass me-1'></i> Search All Flights</a>",
                Server.UrlEncode(details.OriginCity),
                Server.UrlEncode(details.DestinationCity));
        }
    }

    private void ShowAlert(string msg, string type)
    {
        pnlAlert.Visible = true;
        pnlAlert.CssClass = string.Format("alert alert-{0} alert-dismissible fade show shadow-sm", type);
        litAlertMessage.Text = Server.HtmlEncode(msg);
    }
}

