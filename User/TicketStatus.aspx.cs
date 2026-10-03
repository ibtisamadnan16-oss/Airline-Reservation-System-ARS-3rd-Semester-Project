using System;
using System.Web.UI;
using AirlineReservationSystem;

public partial class User_TicketStatus : Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            string queryRef = Request.QueryString["ref"];
            if (!string.IsNullOrWhiteSpace(queryRef))
            {
                txtSearchReference.Text = queryRef.Trim();
                PerformLookup(queryRef.Trim());
            }
        }
        else
        {
            string clearBtn = Request.Form["ctl00$MainContent$btnClear"];
            string eventTarget = Request.Form["__EVENTTARGET"] ?? "";
            if (string.IsNullOrEmpty(clearBtn) && !eventTarget.Contains("btnClear"))
            {
                string formRef = Request.Form["ctl00$MainContent$txtSearchReference"];
                if (!string.IsNullOrWhiteSpace(formRef))
                {
                    txtSearchReference.Text = formRef.Trim();
                    PerformLookup(formRef.Trim());
                }
            }
        }
    }

    protected void btnCheckStatus_Click(object sender, EventArgs e)
    {
        string reference = txtSearchReference.Text.Trim();
        if (string.IsNullOrWhiteSpace(reference))
        {
            ShowAlert("Please enter a valid Booking Reference Number (e.g. BLK-XXXXX or CNF-XXXXX).", "warning");
            return;
        }

        PerformLookup(reference);
    }

    protected void btnClear_Click(object sender, EventArgs e)
    {
        txtSearchReference.Text = "";
        pnlAlert.Visible = false;
        pnlTicketDetails.Visible = false;
        btnClear.Visible = false;
    }

    private void PerformLookup(string reference)
    {
        pnlAlert.Visible = false;
        pnlTicketDetails.Visible = false;

        string errorMessage;
        TicketStatusDetails details = ReservationHelper.GetTicketStatus(reference, out errorMessage);

        if (details == null)
        {
            ShowAlert(errorMessage ?? "Ticket not found. Please verify your reference number and try again.", "danger");
            return;
        }

        pnlTicketDetails.Visible = true;
        btnClear.Visible = true;

        litAirlineName.Text = Server.HtmlEncode(details.AirlineName);
        litFlightNumber.Text = Server.HtmlEncode(details.FlightNumber);
        litBookingRef.Text = Server.HtmlEncode(details.BookingReference);

        string status = details.TicketStatus;
        if (status.Equals("Confirmed", StringComparison.OrdinalIgnoreCase))
        {
            litTicketStatusBadge.Text = "<span class='badge bg-success fs-6'><i class='fa-solid fa-circle-check me-1'></i> Confirmed Ticket</span>";
        }
        else if (status.Equals("Blocked", StringComparison.OrdinalIgnoreCase))
        {
            litTicketStatusBadge.Text = "<span class='badge bg-warning text-dark fs-6'><i class='fa-solid fa-lock me-1'></i> Blocked Reservation</span>";
        }
        else if (status.Equals("Cancelled", StringComparison.OrdinalIgnoreCase))
        {
            litTicketStatusBadge.Text = "<span class='badge bg-danger fs-6'><i class='fa-solid fa-ban me-1'></i> Cancelled</span>";
        }
        else
        {
            litTicketStatusBadge.Text = string.Format("<span class='badge bg-secondary fs-6'>{0}</span>", Server.HtmlEncode(status));
        }

        litOriginCity.Text = Server.HtmlEncode(details.OriginCity);
        litDestinationCity.Text = Server.HtmlEncode(details.DestinationCity);
        litDepartureDate.Text = details.DepartureDateFormatted;
        litDepartureTime.Text = details.DepartureTimeFormatted;
        litArrivalDate.Text = details.ArrivalDateFormatted;
        litArrivalTime.Text = details.ArrivalTimeFormatted;

        litPassengerName.Text = Server.HtmlEncode(details.PassengerName);
        litSeatClass.Text = Server.HtmlEncode(details.SeatClass);
        litTotalPrice.Text = details.TotalPrice.ToString("N2");
        litBookingDate.Text = details.BookingDate.ToString("ddd, dd-MMM-yyyy hh:mm tt");
        litAccountOwner.Text = !string.IsNullOrEmpty(details.CustomerUsername)
            ? string.Format("{0} ({1})", details.CustomerFullName, details.CustomerUsername)
            : "Guest / Direct Passenger";

        if (details.HasTimingChange)
        {
            pnlTimingChangeAlert.Visible = true;
            pnlOnTimeNotice.Visible = false;

            litTimingDifference.Text = !string.IsNullOrEmpty(details.TimingDifferenceFormatted)
                ? details.TimingDifferenceFormatted
                : "Schedule Revised";

            litAlertFlightNumber.Text = details.FlightNumber;
            litOriginalDepSchedule.Text = string.Format("{0} at {1}", details.DepartureDateFormatted, details.DepartureTimeFormatted);
            litRevisedDepSchedule.Text = string.Format("{0} at {1}",
                !string.IsNullOrEmpty(details.RevisedDepartureDateFormatted) ? details.RevisedDepartureDateFormatted : details.DepartureDateFormatted,
                !string.IsNullOrEmpty(details.RevisedDepartureTimeFormatted) ? details.RevisedDepartureTimeFormatted : details.DepartureTimeFormatted);

            litOriginalArrSchedule.Text = string.Format("{0} at {1}", details.ArrivalDateFormatted, details.ArrivalTimeFormatted);
            litRevisedArrSchedule.Text = string.Format("{0} at {1}",
                !string.IsNullOrEmpty(details.RevisedArrivalDateFormatted) ? details.RevisedArrivalDateFormatted : details.ArrivalDateFormatted,
                !string.IsNullOrEmpty(details.RevisedArrivalTimeFormatted) ? details.RevisedArrivalTimeFormatted : details.ArrivalTimeFormatted);

            litTimingReason.Text = !string.IsNullOrWhiteSpace(details.TimingChangeReason)
                ? Server.HtmlEncode(details.TimingChangeReason)
                : "Operational schedule adjustment. Please monitor airport information boards for revised boarding call.";
        }
        else
        {
            pnlTimingChangeAlert.Visible = false;
            pnlOnTimeNotice.Visible = true;
        }

        if (status.Equals("Blocked", StringComparison.OrdinalIgnoreCase))
        {
            litActionButtons.Text = string.Format(
                "<a href='ConfirmBlockedTicket.aspx?ref={0}' class='btn btn-success fw-bold'><i class='fa-solid fa-circle-check me-1'></i> Confirm Ticket</a> " +
                "<a href='CancelTicket.aspx?ref={0}' class='btn btn-outline-danger'><i class='fa-solid fa-ban me-1'></i> Cancel Block</a>",
                details.BookingReference);
        }
        else if (status.Equals("Confirmed", StringComparison.OrdinalIgnoreCase))
        {
            litActionButtons.Text = string.Format(
                "<a href='RescheduleTicket.aspx?cnf={0}' class='btn btn-outline-primary fw-bold'><i class='fa-solid fa-arrows-rotate me-1'></i> Reschedule Flight</a> " +
                "<a href='CancelTicket.aspx?ref={0}' class='btn btn-outline-danger'><i class='fa-solid fa-ban me-1'></i> Cancel Ticket &amp; Refund</a>",
                details.BookingReference);
        }
        else
        {
            litActionButtons.Text = "<span class='badge bg-danger-subtle text-danger border border-danger px-3 py-2'><i class='fa-solid fa-ban me-1'></i> Ticket Cancelled / Processed</span>";
        }
    }

    private void ShowAlert(string msg, string type)
    {
        pnlAlert.Visible = true;
        pnlAlert.CssClass = string.Format("alert alert-{0} alert-dismissible fade show", type);
        litAlertMessage.Text = string.Format("<i class='fa-solid fa-{0} me-2'></i> {1}",
            type == "danger" ? "circle-xmark" : "triangle-exclamation",
            msg);
    }
}

