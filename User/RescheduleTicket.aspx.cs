using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using AirlineReservationSystem;

public partial class User_RescheduleTicket : Page
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
            if (!string.IsNullOrEmpty(Request.QueryString["cnf"]))
            {
                txtConfirmationNumber.Text = Request.QueryString["cnf"].Trim();
                RetrieveTicket(txtConfirmationNumber.Text);
            }
        }
    }

    protected void btnRetrieveTicket_Click(object sender, EventArgs e)
    {
        RetrieveTicket(txtConfirmationNumber.Text.Trim());
    }

    private void RetrieveTicket(string cnfNum)
    {
        pnlAlertMessage.Visible = false;
        pnlTicketDetails.Visible = false;
        pnlAlternateFlights.Visible = false;
        pnlConfirmReschedule.Visible = false;
        pnlRescheduleSuccess.Visible = false;

        if (string.IsNullOrWhiteSpace(cnfNum))
        {
            ShowAlert("Please enter a valid Confirmation Number (e.g. CNF-45872).", "danger");
            return;
        }

        string errorMessage;
        RescheduleTicketDetails details = ReservationHelper.GetTicketForReschedule(cnfNum, out errorMessage);
        if (details == null)
        {
            ShowAlert(errorMessage ?? "Reservation not found. Please verify the confirmation number.", "warning");
            return;
        }

        if (!details.IsEligibleForReschedule)
        {
            ShowAlert("<i class='fa-solid fa-ban me-2'></i><strong>Reschedule Not Allowed:</strong> " + details.IneligibilityReason, "danger");
            return;
        }

        btnResetForm.Visible = true;
        pnlTicketDetails.Visible = true;

        litOldRef.Text = Server.HtmlEncode(details.BookingReference);
        litPassengerName.Text = Server.HtmlEncode(details.PassengerName);
        litSeatClass.Text = Server.HtmlEncode(details.SeatClass);
        litOldFlight.Text = Server.HtmlEncode(details.AirlineName + " (" + details.FlightNumber + ")");
        litOldOrigin.Text = Server.HtmlEncode(details.OriginCity);
        litOldDest.Text = Server.HtmlEncode(details.DestinationCity);
        litOldDepDate.Text = details.DepartureTime.ToString("dddd, dd-MMM-yyyy hh:mm tt");
        litOldPrice.Text = details.TotalPrice.ToString("N2");

        hfReservationId.Value = details.ReservationId.ToString();
        hfUserId.Value = details.UserId.ToString();
        hfOldFlightId.Value = details.FlightId.ToString();
        hfOldPrice.Value = details.TotalPrice.ToString();
        hfOriginCity.Value = details.OriginCity;
        hfDestinationCity.Value = details.DestinationCity;
        hfSeatClass.Value = details.SeatClass;

        if (string.IsNullOrEmpty(txtNewDepartureDate.Text))
        {
            DateTime suggested = details.DepartureTime.AddDays(7);
            if (suggested < DateTime.Today) suggested = DateTime.Today.AddDays(3);
            txtNewDepartureDate.Text = suggested.ToString("yyyy-MM-dd");
        }
    }

    protected void btnSearchAlternateFlights_Click(object sender, EventArgs e)
    {
        pnlAlertMessage.Visible = false;
        DateTime newDate;
        if (!DateTime.TryParse(txtNewDepartureDate.Text, out newDate))
        {
            ShowAlert("Please select a valid new departure date.", "warning");
            return;
        }

        if (newDate.Date < DateTime.Today)
        {
            ShowAlert("New departure date cannot be in the past. Please select today or a future date.", "warning");
            return;
        }

        string origin = hfOriginCity.Value;
        string dest = hfDestinationCity.Value;
        int oldFlightId = Convert.ToInt32(hfOldFlightId.Value);
        string seatClass = hfSeatClass.Value;

        DataTable dt = ReservationHelper.GetAlternateFlightsForReschedule(origin, dest, newDate, oldFlightId, seatClass);
        if (dt != null && dt.Rows.Count > 0)
        {
            rptAlternateFlights.DataSource = dt;
            rptAlternateFlights.DataBind();
            pnlAlternateFlights.Visible = true;
            pnlNoAlternateFlights.Visible = false;
        }
        else
        {
            rptAlternateFlights.DataSource = null;
            rptAlternateFlights.DataBind();
            pnlAlternateFlights.Visible = true;
            pnlNoAlternateFlights.Visible = true;
        }

        pnlConfirmReschedule.Visible = false;
    }

    protected void rptAlternateFlights_ItemCommand(object source, RepeaterCommandEventArgs e)
    {
        if (e.CommandName == "SelectFlight")
        {
            string[] parts = e.CommandArgument.ToString().Split(';');
            int selectedFlightId = Convert.ToInt32(parts[0]);
            decimal newPrice = Convert.ToDecimal(parts[1]);
            string flightNumber = parts[2];
            string depTimeStr = parts[3];

            hfSelectedNewFlightId.Value = selectedFlightId.ToString();
            hfSelectedNewPrice.Value = newPrice.ToString();

            decimal oldPrice = Convert.ToDecimal(hfOldPrice.Value);
            decimal diff = newPrice - oldPrice;

            litReviewOldPrice.Text = oldPrice.ToString("N2");
            litReviewNewPrice.Text = newPrice.ToString("N2");
            litReviewNewFlightNum.Text = Server.HtmlEncode(flightNumber);
            litReviewNewDepDate.Text = Server.HtmlEncode(depTimeStr);

            if (diff > 0)
            {
                divAdjustmentCard.Attributes["class"] = "p-3 rounded border bg-warning-subtle border-warning";
                spnAdjustmentAmount.Attributes["class"] = "fs-5 fw-bold text-danger";
                litReviewDiff.Text = "+PKR " + diff.ToString("N2");
                spnAdjustmentType.Attributes["class"] = "d-block mt-1 fw-semibold text-danger";
                litReviewAdjustmentDescription.Text = "Extra Charge Required (New Price > Old Price)";
            }
            else if (diff < 0)
            {
                divAdjustmentCard.Attributes["class"] = "p-3 rounded border bg-success-subtle border-success";
                spnAdjustmentAmount.Attributes["class"] = "fs-5 fw-bold text-success";
                litReviewDiff.Text = "-PKR " + Math.Abs(diff).ToString("N2");
                spnAdjustmentType.Attributes["class"] = "d-block mt-1 fw-semibold text-success";
                litReviewAdjustmentDescription.Text = "Refund / Account Credit Issued (New Price < Old Price)";
            }
            else
            {
                divAdjustmentCard.Attributes["class"] = "p-3 rounded border bg-light";
                spnAdjustmentAmount.Attributes["class"] = "fs-5 fw-bold text-dark";
                litReviewDiff.Text = "PKR 0.00";
                spnAdjustmentType.Attributes["class"] = "d-block mt-1 fw-semibold text-muted";
                litReviewAdjustmentDescription.Text = "Even Exchange (No Price Difference)";
            }

            pnlConfirmReschedule.Visible = true;
        }
    }

    protected void btnConfirmRescheduleAction_Click(object sender, EventArgs e)
    {
        int resId = 0, userId = 0, oldFlightId = 0, newFlightId = 0;
        int.TryParse(hfReservationId.Value, out resId);
        int.TryParse(hfUserId.Value, out userId);
        int.TryParse(hfOldFlightId.Value, out oldFlightId);
        int.TryParse(hfSelectedNewFlightId.Value, out newFlightId);

        if (resId == 0)
        {
            string cnf = txtConfirmationNumber.Text.Trim();
            string lookupErr;
            RescheduleTicketDetails details = ReservationHelper.GetTicketForReschedule(cnf, out lookupErr);
            if (details != null)
            {
                resId = details.ReservationId;
                userId = details.UserId;
                oldFlightId = details.FlightId;
            }
        }

        if (resId == 0 || newFlightId == 0)
        {
            ShowAlert("Please select an alternate flight to reschedule.", "warning");
            return;
        }

        string oldCnf = !string.IsNullOrEmpty(litOldRef.Text) ? litOldRef.Text.Trim() : txtConfirmationNumber.Text.Trim();
        decimal oldPrice = Convert.ToDecimal(hfOldPrice.Value);
        decimal newPrice = Convert.ToDecimal(hfSelectedNewPrice.Value);

        RescheduleResult result = ReservationHelper.ExecuteReschedule(
            resId, userId, oldCnf, oldFlightId, newFlightId, oldPrice, newPrice, 1);

        if (result.Success)
        {
            pnlTicketDetails.Visible = false;
            pnlAlternateFlights.Visible = false;
            pnlConfirmReschedule.Visible = false;
            pnlRescheduleSuccess.Visible = true;

            litSuccessOldCnf.Text = result.OldConfirmationNumber;
            litSuccessNewCnf.Text = result.NewConfirmationNumber;
            litPipelineOldCnf.Text = result.OldConfirmationNumber;
            litPipelineNewCnf.Text = result.NewConfirmationNumber;
            litSuccessDiffOutcome.Text = result.PriceAdjustmentDescription;

            ShowAlert(string.Format("Success! Your flight ticket has been rescheduled under New Confirmation Number '{0}'.", result.NewConfirmationNumber), "success");
        }
        else
        {
            ShowAlert("Rescheduling failed: " + result.ErrorMessage, "danger");
        }
    }

    protected void btnResetForm_Click(object sender, EventArgs e)
    {
        txtConfirmationNumber.Text = "";
        pnlTicketDetails.Visible = false;
        pnlAlternateFlights.Visible = false;
        pnlConfirmReschedule.Visible = false;
        pnlRescheduleSuccess.Visible = false;
        pnlAlertMessage.Visible = false;
        btnResetForm.Visible = false;
    }

    private void ShowAlert(string message, string cssClass)
    {
        pnlAlertMessage.Visible = true;
        pnlAlertMessage.CssClass = "alert alert-" + cssClass + " alert-dismissible fade show mb-4";
        litAlertMessage.Text = message;
    }
}

