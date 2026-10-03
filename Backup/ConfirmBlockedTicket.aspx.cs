using System;
using System.Web.UI;
using AirlineReservationSystem;

public partial class ConfirmBlockedTicket : Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        // Only registered users allowed
        if (!UserStateHelper.IsLoggedIn)
        {
            Response.Redirect("~/Login.aspx?msg=auth_required");
            return;
        }

        if (!IsPostBack)
        {
            if (!string.IsNullOrEmpty(Request.QueryString["blk"]))
            {
                txtBlockingNumber.Text = Request.QueryString["blk"].Trim();
                RetrieveBlock(txtBlockingNumber.Text);
            }
        }
    }

    protected void btnRetrieveBlock_Click(object sender, EventArgs e)
    {
        string refNum = txtBlockingNumber.Text.Trim();
        RetrieveBlock(refNum);
    }

    private void RetrieveBlock(string refNum)
    {
        pnlBlockMessage.Visible = false;
        pnlBlockDetails.Visible = false;
        pnlConfirmationSuccess.Visible = false;

        if (string.IsNullOrWhiteSpace(refNum))
        {
            ShowBlockMessage("Please enter a valid Blocking Number (e.g. BLK-17891).", "danger");
            return;
        }

        string errorMessage;
        BlockedReservationDetails details = ReservationHelper.GetBlockedReservationDetails(refNum, out errorMessage);
        if (details == null)
        {
            ShowBlockMessage(errorMessage ?? "Reservation not found.", "warning");
            return;
        }

        btnResetBlockSearch.Visible = true;
        pnlBlockDetails.Visible = true;

        litDetailsRef.Text = Server.HtmlEncode(details.BookingReference);
        litDetailsStatus.Text = Server.HtmlEncode(details.Status);
        litDetailsPassenger.Text = Server.HtmlEncode(details.PassengerName);
        litDetailsFlight.Text = Server.HtmlEncode(details.AirlineName + " (" + details.FlightNumber + ")");
        litDetailsClass.Text = Server.HtmlEncode(details.SeatClass);
        litDetailsOrigin.Text = Server.HtmlEncode(details.OriginCity);
        litDetailsDest.Text = Server.HtmlEncode(details.DestinationCity);
        litDetailsDepTime.Text = details.DepartureTime.ToString("dddd, dd-MMM-yyyy hh:mm tt");
        litDetailsArrTime.Text = details.ArrivalTime.ToString("dddd, dd-MMM-yyyy hh:mm tt");
        litDetailsPrice.Text = details.TotalPrice.ToString("N2");

        txtPaymentCardNumber.Text = !string.IsNullOrEmpty(details.PreferredCreditCard) ? details.PreferredCreditCard : "";
        hfReservationId.Value = details.ReservationId.ToString();
        hfFlightId.Value = details.FlightId.ToString();
        hfUserId.Value = details.UserId.ToString();

        if (details.IsEligibleForConfirmation)
        {
            litDetailsDaysNotice.Text = string.Format(
                "<span class='badge bg-success me-1'><i class='fa-solid fa-circle-check'></i> 2-Week Rule Satisfied</span> <span class='text-success fw-bold'>{0} days remaining</span> before departure. Meets policy requirements (&ge; 14 days). Ticket is valid for confirmation.",
                details.DaysUntilDeparture);
            btnConfirmPayment.Visible = true;
            btnCancelExpired.Visible = false;
        }
        else
        {
            litDetailsDaysNotice.Text = string.Format(
                "<span class='badge bg-danger me-1'><i class='fa-solid fa-triangle-exclamation'></i> 2-Week Rule Violation</span> <span class='text-danger fw-bold'>Departure is in {0} day(s)</span> (less than 14 days). Per airline policy, blocked tickets must be confirmed at least 2 weeks (14 days) prior to departure. This reservation has expired and cannot be confirmed.",
                details.DaysUntilDeparture);
            btnConfirmPayment.Visible = false;
            btnCancelExpired.Visible = (details.Status.Equals("Blocked", StringComparison.OrdinalIgnoreCase));
        }
    }

    protected void btnConfirmPayment_Click(object sender, EventArgs e)
    {
        int resId = 0, userId = 0;
        int.TryParse(hfReservationId.Value, out resId);
        int.TryParse(hfUserId.Value, out userId);

        if (resId == 0)
        {
            string refNum = txtBlockingNumber.Text.Trim();
            string lookupErr;
            BlockedReservationDetails details = ReservationHelper.GetBlockedReservationDetails(refNum, out lookupErr);
            if (details != null)
            {
                resId = details.ReservationId;
                userId = details.UserId;
            }
        }

        if (resId == 0)
        {
            ShowBlockMessage("Invalid reservation reference. Please retrieve ticket again.", "danger");
            return;
        }

        string oldRef = !string.IsNullOrEmpty(litDetailsRef.Text) ? litDetailsRef.Text.Trim() : txtBlockingNumber.Text.Trim();
        string paymentCard = txtPaymentCardNumber.Text.Trim();
        string newCnf;
        string error;

        bool success = ReservationHelper.ConfirmBlockedReservation(resId, userId, oldRef, paymentCard, out newCnf, out error);
        if (success)
        {
            pnlBlockDetails.Visible = false;
            pnlConfirmationSuccess.Visible = true;
            litSuccessOldRef.Text = oldRef;
            litSuccessNewRef.Text = newCnf;
            litSuccessPipelineOld.Text = oldRef;
            litSuccessPipelineCnf.Text = newCnf;
            ShowBlockMessage(string.Format("Success! Blocked reservation '{0}' has been confirmed under Confirmation Number '{1}'.", oldRef, newCnf), "success");
        }
        else
        {
            ShowBlockMessage("Confirmation failed: " + error, "danger");
        }
    }

    protected void btnCancelExpired_Click(object sender, EventArgs e)
    {
        int resId = 0, flightId = 0;
        int.TryParse(hfReservationId.Value, out resId);
        int.TryParse(hfFlightId.Value, out flightId);

        if (resId == 0)
        {
            string refNum = txtBlockingNumber.Text.Trim();
            string lookupErr;
            BlockedReservationDetails details = ReservationHelper.GetBlockedReservationDetails(refNum, out lookupErr);
            if (details != null)
            {
                resId = details.ReservationId;
                flightId = details.FlightId;
            }
        }

        if (resId == 0)
        {
            ShowBlockMessage("Invalid reservation reference.", "danger");
            return;
        }

        string error;
        bool success = ReservationHelper.CancelExpiredBlock(resId, flightId, out error);
        if (success)
        {
            pnlBlockDetails.Visible = false;
            ShowBlockMessage("Expired block reservation has been cancelled and seat returned to flight inventory.", "info");
        }
        else
        {
            ShowBlockMessage("Cancellation failed: " + error, "danger");
        }
    }

    protected void btnResetBlockSearch_Click(object sender, EventArgs e)
    {
        txtBlockingNumber.Text = "";
        pnlBlockDetails.Visible = false;
        pnlConfirmationSuccess.Visible = false;
        pnlBlockMessage.Visible = false;
        btnResetBlockSearch.Visible = false;
    }

    private void ShowBlockMessage(string message, string cssClass)
    {
        pnlBlockMessage.Visible = true;
        pnlBlockMessage.CssClass = "alert alert-" + cssClass + " alert-dismissible fade show mb-4";
        litBlockMessage.Text = "<i class='fa-solid fa-circle-info me-2'></i>" + Server.HtmlEncode(message);
    }
}
