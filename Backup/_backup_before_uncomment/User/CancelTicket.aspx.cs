using System;
using System.Web.UI;
using AirlineReservationSystem;

public partial class User_CancelTicket : Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!UserStateHelper.IsLoggedIn)
        {
            Response.Redirect("~/Public/Login.aspx?msg=auth_required");
            return;
        }

        if (!IsPostBack)
        {
            string queryRef = Request.QueryString["ref"];
            if (!string.IsNullOrWhiteSpace(queryRef))
            {
                txtBookingReference.Text = queryRef.Trim();
                PerformLookup(queryRef.Trim());
            }
        }
    }

    protected void btnLookupTicket_Click(object sender, EventArgs e)
    {
        string refNumber = txtBookingReference.Text.Trim();
        if (string.IsNullOrWhiteSpace(refNumber))
        {
            ShowAlert("Please enter a booking reference number (e.g. BLK-XXXXX or CNF-XXXXX).", "warning");
            return;
        }

        PerformLookup(refNumber);
    }

    protected void btnClearLookup_Click(object sender, EventArgs e)
    {
        txtBookingReference.Text = "";
        HideAllPanels();
        btnClearLookup.Visible = false;
    }

    private void PerformLookup(string reference)
    {
        HideAllPanels();
        string errorMessage;
        CancellationTicketDetails details = ReservationHelper.GetTicketForCancellation(reference, out errorMessage);

        if (details == null)
        {
            ShowAlert(errorMessage ?? "Reservation not found. Please check your reference number and try again.", "danger");
            return;
        }

        if (!details.IsEligibleForCancellation)
        {
            ShowAlert(details.IneligibilityReason ?? "This reservation is not eligible for cancellation.", "warning");
            return;
        }

        // Populate hidden fields for robust state handling across postbacks
        hfReservationId.Value = details.ReservationId.ToString();
        hfUserId.Value = details.UserId.ToString();
        hfFlightId.Value = details.FlightId.ToString();
        hfBookingReference.Value = details.BookingReference;
        hfTicketType.Value = details.Status;
        hfTotalPrice.Value = details.TotalPrice.ToString();
        hfRefundAmount.Value = details.RefundAmount.ToString();
        hfSkyMilesToDeduct.Value = details.SkyMilesToDeduct.ToString();

        btnClearLookup.Visible = true;

        if (details.IsBlockedTicket)
        {
            // Case 1: Blocked Ticket
            litBlockedRef.Text = details.BookingReference;
            litBlockedFlightNumber.Text = details.FlightNumber;
            litBlockedAirline.Text = details.AirlineName;
            litBlockedRoute.Text = details.OriginCity + " â†’ " + details.DestinationCity;
            litBlockedSchedule.Text = details.DepartureTime.ToString("ddd, dd MMM yyyy hh:mm tt");
            litBlockedPassenger.Text = details.PassengerName;
            litBlockedClass.Text = details.SeatClass;
            litBlockedDays.Text = details.DaysUntilDeparture.ToString();

            pnlBlockedTicket.Visible = true;
        }
        else if (details.IsConfirmedTicket)
        {
            // Case 2: Confirmed Ticket
            litConfirmedRef.Text = details.BookingReference;
            litConfirmedFlightNumber.Text = details.FlightNumber;
            litConfirmedAirline.Text = details.AirlineName;
            litConfirmedRoute.Text = details.OriginCity + " â†’ " + details.DestinationCity;
            litConfirmedSchedule.Text = details.DepartureTime.ToString("ddd, dd MMM yyyy hh:mm tt");
            litConfirmedPassenger.Text = details.PassengerName;
            litConfirmedClass.Text = details.SeatClass;
            litConfirmedDays.Text = details.DaysUntilDeparture.ToString();

            litOriginalPrice.Text = details.TotalPrice.ToString("N2");
            litRefundPercentage.Text = details.RefundPercentage.ToString();
            litPenaltyPercentage.Text = details.DeductionPercentage.ToString();
            litCancellationFee.Text = details.CancellationFee.ToString("N2");
            litNetRefundAmount.Text = details.RefundAmount.ToString("N2");

            HighlightPolicyMatrix(details.DaysUntilDeparture);
            pnlConfirmedTicket.Visible = true;
        }
    }

    private void HighlightPolicyMatrix(int daysUntilDep)
    {
        // Reset row styles
        rowPolicy30.Attributes["class"] = "";
        rowPolicy15.Attributes["class"] = "";
        rowPolicyLess15.Attributes["class"] = "";
        rowPolicy24h.Attributes["class"] = "";

        litBadgePolicy30.Text = "<span class='badge bg-secondary'>Applicable if &gt;= 30 days</span>";
        litBadgePolicy15.Text = "<span class='badge bg-secondary'>Applicable if 15-30 days</span>";
        litBadgePolicyLess15.Text = "<span class='badge bg-secondary'>Applicable if 1-14 days</span>";
        litBadgePolicy24h.Text = "<span class='badge bg-secondary'>Non-refundable</span>";

        if (daysUntilDep >= 30)
        {
            rowPolicy30.Attributes["class"] = "table-success border border-success fw-bold";
            litBadgePolicy30.Text = "<span class='badge bg-success'><i class='fa-solid fa-check me-1'></i> Active Policy Applied (90% Refund)</span>";
        }
        else if (daysUntilDep >= 15)
        {
            rowPolicy15.Attributes["class"] = "table-primary border border-primary fw-bold";
            litBadgePolicy15.Text = "<span class='badge bg-primary'><i class='fa-solid fa-check me-1'></i> Active Policy Applied (70% Refund)</span>";
        }
        else if (daysUntilDep >= 1)
        {
            rowPolicyLess15.Attributes["class"] = "table-warning border border-warning fw-bold";
            litBadgePolicyLess15.Text = "<span class='badge bg-warning text-dark'><i class='fa-solid fa-check me-1'></i> Active Policy Applied (40% Refund)</span>";
        }
        else
        {
            rowPolicy24h.Attributes["class"] = "table-danger border border-danger fw-bold";
            litBadgePolicy24h.Text = "<span class='badge bg-danger'><i class='fa-solid fa-check me-1'></i> Active Policy Applied (Non-Refundable)</span>";
        }
    }

    protected void btnCancelBlockedTicket_Click(object sender, EventArgs e)
    {
        // Read parameters or fall back to fresh lookup
        int reservationId, userId, flightId;
        string reference = hfBookingReference.Value;
        if (string.IsNullOrWhiteSpace(reference))
        {
            reference = txtBookingReference.Text.Trim();
        }

        string err;
        CancellationTicketDetails details = ReservationHelper.GetTicketForCancellation(reference, out err);
        if (details == null || !details.IsBlockedTicket)
        {
            ShowAlert(err ?? "Invalid blocked ticket for cancellation.", "danger");
            return;
        }

        reservationId = details.ReservationId;
        userId = details.UserId;
        flightId = details.FlightId;

        CancellationResult result = ReservationHelper.ExecuteCancellation(
            reservationId,
            userId,
            flightId,
            reference,
            "Blocked",
            0m,
            0);

        if (result.Success)
        {
            HideAllPanels();
            pnlSuccessReceipt.Visible = true;
            litResultCancellationNumber.Text = result.CancellationNumber;
            litResultOldReference.Text = result.OldReference;
            litResultRefundAmount.Text = "0.00 (No payment charged for blocked reservation)";
            litResultSkyMilesDeducted.Text = "0";
        }
        else
        {
            ShowAlert("Cancellation failed: " + result.ErrorMessage, "danger");
        }
    }

    protected void btnConfirmCancellation_Click(object sender, EventArgs e)
    {
        // Read parameters or fall back to fresh lookup
        string reference = hfBookingReference.Value;
        if (string.IsNullOrWhiteSpace(reference))
        {
            reference = txtBookingReference.Text.Trim();
        }

        string err;
        CancellationTicketDetails details = ReservationHelper.GetTicketForCancellation(reference, out err);
        if (details == null || !details.IsConfirmedTicket)
        {
            ShowAlert(err ?? "Invalid confirmed ticket for cancellation.", "danger");
            return;
        }

        CancellationResult result = ReservationHelper.ExecuteCancellation(
            details.ReservationId,
            details.UserId,
            details.FlightId,
            reference,
            "Confirmed",
            details.RefundAmount,
            details.SkyMilesToDeduct);

        if (result.Success)
        {
            HideAllPanels();
            pnlSuccessReceipt.Visible = true;
            litResultCancellationNumber.Text = result.CancellationNumber;
            litResultOldReference.Text = result.OldReference;
            litResultRefundAmount.Text = string.Format("{0:N2} ({1}% of ticket fare)", result.RefundAmount, details.RefundPercentage);
            litResultSkyMilesDeducted.Text = result.SkyMilesDeducted.ToString();
        }
        else
        {
            ShowAlert("Cancellation failed: " + result.ErrorMessage, "danger");
        }
    }

    private void HideAllPanels()
    {
        pnlAlert.Visible = false;
        pnlBlockedTicket.Visible = false;
        pnlConfirmedTicket.Visible = false;
        pnlSuccessReceipt.Visible = false;
    }

    private void ShowAlert(string message, string alertType)
    {
        pnlAlert.CssClass = string.Format("alert alert-{0} alert-dismissible fade show", alertType);
        litAlertMessage.Text = string.Format("<i class='fa-solid fa-{0} me-2'></i> {1}",
            alertType == "danger" ? "circle-xmark" : (alertType == "warning" ? "triangle-exclamation" : "circle-check"),
            message);
        pnlAlert.Visible = true;
    }
}

