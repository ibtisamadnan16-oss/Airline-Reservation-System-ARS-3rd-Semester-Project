using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using AirlineReservationSystem;

public partial class Dashboard : Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        // Protect Dashboard: only registered logged in users allowed
        if (!UserStateHelper.IsLoggedIn)
        {
            Response.Redirect("~/Login.aspx?msg=auth_required");
            return;
        }

        if (!IsPostBack)
        {
            LoadUserProfile();
            LoadReservations();

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
                "<span class='badge bg-danger me-1'><i class='fa-solid fa-triangle-exclamation'></i> 2-Week Rule Violation</span> <span class='text-danger fw-bold'>Departure is in {0} day(s)</span> (less than 14 days). Per airline policy, blocked tickets must be confirmed at least 2 weeks (14 days) prior to departure. This reservation is expired and cannot be confirmed.",
                details.DaysUntilDeparture);
            btnConfirmPayment.Visible = false;
            btnCancelExpired.Visible = (details.Status.Equals("Blocked", StringComparison.OrdinalIgnoreCase));
        }
    }

    protected void btnConfirmPayment_Click(object sender, EventArgs e)
    {
        int resId, userId;
        if (!int.TryParse(hfReservationId.Value, out resId) || !int.TryParse(hfUserId.Value, out userId))
        {
            ShowBlockMessage("Invalid reservation reference. Please retrieve ticket again.", "danger");
            return;
        }

        string oldRef = litDetailsRef.Text.Trim();
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

            // Reload user miles & reservation list
            LoadUserProfile();
            LoadReservations();
            ShowBlockMessage(string.Format("Success! Blocked reservation '{0}' has been confirmed under Confirmation Number '{1}'.", oldRef, newCnf), "success");
        }
        else
        {
            ShowBlockMessage("Confirmation failed: " + error, "danger");
        }
    }

    protected void btnCancelExpired_Click(object sender, EventArgs e)
    {
        int resId, flightId;
        if (!int.TryParse(hfReservationId.Value, out resId) || !int.TryParse(hfFlightId.Value, out flightId))
        {
            ShowBlockMessage("Invalid reservation reference.", "danger");
            return;
        }

        string error;
        bool success = ReservationHelper.CancelExpiredBlock(resId, flightId, out error);
        if (success)
        {
            pnlBlockDetails.Visible = false;
            LoadReservations();
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
        pnlBlockMessage.CssClass = "alert alert-" + cssClass + " alert-dismissible fade show mb-3";
        litBlockMessage.Text = "<i class='fa-solid fa-circle-info me-2'></i>" + Server.HtmlEncode(message);
    }

    private void LoadUserProfile()
    {
        int userId = UserStateHelper.CurrentUserId;
        try
        {
            string query = "SELECT Username, FirstName, LastName, Email, PhoneNumber, Gender, Age, Address, PreferredCreditCard, SkyMiles, Role FROM Users WHERE UserId = @UserId";
            SqlParameter[] parameters = new SqlParameter[]
            {
                new SqlParameter("@UserId", userId)
            };

            DataTable dt = DbHelper.ExecuteQuery(query, parameters);
            if (dt.Rows.Count > 0)
            {
                DataRow r = dt.Rows[0];
                string fullName = r["FirstName"] + " " + r["LastName"];
                litFullName.Text = Server.HtmlEncode(fullName);
                litUsername.Text = Server.HtmlEncode(r["Username"].ToString());
                litRole.Text = Server.HtmlEncode(r["Role"].ToString());
                litSkyMiles.Text = r["SkyMiles"].ToString();

                litTblName.Text = Server.HtmlEncode(fullName);
                litTblEmail.Text = Server.HtmlEncode(r["Email"].ToString());
                litTblPhone.Text = Server.HtmlEncode(r["PhoneNumber"].ToString());
                litTblGenderAge.Text = Server.HtmlEncode(r["Gender"] + ", " + r["Age"] + " yrs");
                litTblAddress.Text = Server.HtmlEncode(r["Address"].ToString());
                
                string card = r["PreferredCreditCard"].ToString();
                litTblCard.Text = string.IsNullOrEmpty(card) ? "Not Specified" : Server.HtmlEncode(card);
                litTblMiles.Text = r["SkyMiles"] + " Miles";
            }
        }
        catch (Exception ex)
        {
            // Fallback to session details
            litFullName.Text = UserStateHelper.CurrentFullName;
            litUsername.Text = UserStateHelper.CurrentUsername;
            litSkyMiles.Text = UserStateHelper.CurrentSkyMiles.ToString();
        }
    }

    private void LoadReservations()
    {
        int userId = UserStateHelper.CurrentUserId;
        try
        {
            string query = @"
                SELECT r.ReservationId, r.BookingReference, r.SeatClass, r.Status, r.TotalPrice, r.BookingDate,
                       f.FlightNumber, f.AirlineName, f.OriginCity, f.DestinationCity, f.DepartureTime
                FROM Reservations r
                INNER JOIN Flights f ON r.FlightId = f.FlightId
                WHERE r.UserId = @UserId
                ORDER BY r.BookingDate DESC";

            SqlParameter[] parameters = new SqlParameter[]
            {
                new SqlParameter("@UserId", userId)
            };

            DataTable dt = DbHelper.ExecuteQuery(query, parameters);
            if (dt.Rows.Count > 0)
            {
                rptReservations.DataSource = dt;
                rptReservations.DataBind();
                pnlNoReservations.Visible = false;

                int confirmed = 0;
                int blocked = 0;
                int cancelled = 0;
                foreach (DataRow row in dt.Rows)
                {
                    string status = row["Status"].ToString();
                    if (status.Equals("Confirmed", StringComparison.OrdinalIgnoreCase)) confirmed++;
                    else if (status.Equals("Blocked", StringComparison.OrdinalIgnoreCase)) blocked++;
                    else if (status.Equals("Cancelled", StringComparison.OrdinalIgnoreCase)) cancelled++;
                }
                litConfirmedCount.Text = confirmed.ToString();
                litBlockedCount.Text = blocked.ToString();
                litCancelledCount.Text = cancelled.ToString();
            }
            else
            {
                rptReservations.Visible = false;
                pnlNoReservations.Visible = true;
            }
        }
        catch
        {
            rptReservations.Visible = false;
            pnlNoReservations.Visible = true;
        }
    }

    public string RenderActionButtons(object statusObj, object refObj)
    {
        string status = statusObj != null ? statusObj.ToString() : "";
        string bookingRef = refObj != null ? refObj.ToString() : "";

        if (status.Equals("Blocked", StringComparison.OrdinalIgnoreCase))
        {
            return string.Format(
                "<div class='btn-group btn-group-sm'>" +
                "<a href='TicketStatus.aspx?ref={0}' class='btn btn-outline-info fw-semibold' title='View Live Flight & Ticket Status'><i class='fa-solid fa-receipt me-1'></i> Status</a>" +
                "<a href='Dashboard.aspx?blk={0}#confirm-ticket-module' class='btn btn-success fw-bold' title='Confirm this Blocked Ticket'><i class='fa-solid fa-circle-check me-1'></i> Confirm</a>" +
                "<a href='CancelTicket.aspx?ref={0}' class='btn btn-outline-danger fw-semibold' title='Cancel this Blocked Reservation'><i class='fa-solid fa-ban me-1'></i> Cancel</a>" +
                "</div>", bookingRef);
        }
        else if (status.Equals("Confirmed", StringComparison.OrdinalIgnoreCase))
        {
            return string.Format(
                "<div class='btn-group btn-group-sm'>" +
                "<a href='TicketStatus.aspx?ref={0}' class='btn btn-outline-info fw-semibold' title='View Live Flight & Ticket Status'><i class='fa-solid fa-receipt me-1'></i> Status</a>" +
                "<a href='RescheduleTicket.aspx?cnf={0}' class='btn btn-outline-primary fw-semibold' title='Reschedule this Flight Ticket'><i class='fa-solid fa-arrows-rotate me-1'></i> Reschedule</a>" +
                "<a href='CancelTicket.aspx?ref={0}' class='btn btn-outline-danger fw-semibold' title='Cancel this Confirmed Ticket'><i class='fa-solid fa-ban me-1'></i> Cancel</a>" +
                "</div>", bookingRef);
        }
        else
        {
            return string.Format(
                "<div class='btn-group btn-group-sm'>" +
                "<a href='TicketStatus.aspx?ref={0}' class='btn btn-outline-secondary fw-semibold' title='View Ticket Status Details'><i class='fa-solid fa-receipt me-1'></i> Status</a>" +
                "</div>", bookingRef);
        }
    }
}
