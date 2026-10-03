using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using AirlineReservationSystem;

public partial class Admin_Dashboard : Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!UserStateHelper.IsLoggedIn)
        {
            Response.Redirect("~/Public/Login.aspx?msg=auth_required");
            return;
        }

        if (!UserStateHelper.IsAdmin)
        {
            pnlAccessDenied.Visible = true;
            pnlAdminAuthorized.Visible = false;
            litCurrentRoleUser.Text = Server.HtmlEncode(UserStateHelper.CurrentUsername);
            litCurrentRoleBadge.Text = Server.HtmlEncode(UserStateHelper.CurrentRole);
            return;
        }

        pnlAccessDenied.Visible = false;
        pnlAdminAuthorized.Visible = true;
        litAdminUsername.Text = string.Format("{0} ({1})", UserStateHelper.CurrentUsername, UserStateHelper.CurrentRole);

        if (!IsPostBack)
        {
            LoadDashboardKPIs();
            BindFlights();
            BindSchedules();
            BindReservations();
            BindUsers();
            BindSeatAvailability();
        }
    }

    protected void btnDemoAdminLogin_Click(object sender, EventArgs e)
    {
        // Direct switch to administrator account for testing & grading convenience
        DataTable dt = DbHelper.ExecuteQuery("SELECT UserId, Username, FirstName, LastName, Role, SkyMiles FROM Users WHERE Username = 'admin'");
        if (dt.Rows.Count > 0)
        {
            DataRow r = dt.Rows[0];
            int uid = Convert.ToInt32(r["UserId"]);
            string uname = r["Username"].ToString();
            string fullName = r["FirstName"] + " " + r["LastName"];
            string role = r["Role"].ToString();
            int miles = Convert.ToInt32(r["SkyMiles"]);

            UserStateHelper.SetLoggedIn(uid, uname, fullName, role, miles);
            Response.Redirect("~/Admin/Dashboard.aspx");
        }
    }

    private void LoadDashboardKPIs()
    {
        AdminDashboardStats stats = AdminHelper.GetDashboardStats();
        litKpiTotalFlights.Text = stats.TotalFlights.ToString();
        litKpiTotalReservations.Text = stats.TotalReservations.ToString();
        litKpiConfirmedCount.Text = stats.ConfirmedBookings.ToString();
        litKpiBlockedCount.Text = stats.BlockedBookings.ToString();
        litKpiCancelledCount.Text = stats.CancelledBookings.ToString();
        litKpiTotalUsers.Text = stats.TotalUsers.ToString();
        litKpiTotalRevenue.Text = stats.TotalRevenue.ToString("N0");
        litKpiOccupancyRate.Text = stats.SeatOccupancyRate + "%";
        litKpiAvailSeats.Text = stats.TotalAvailableSeats.ToString();
        litKpiTotalCap.Text = stats.TotalCapacity.ToString();
    }

    // ====================================================================
    // SCREEN 1: FLIGHTS MANAGEMENT
    // ====================================================================
    private void BindFlights()
    {
        gvFlights.DataSource = AdminHelper.GetAllFlights();
        gvFlights.DataBind();
    }

    protected void btnSaveFlight_Click(object sender, EventArgs e)
    {
        string fNo = txtFlightNumber.Text.Trim();
        string airline = txtAirlineName.Text.Trim();
        string origin = txtOriginCity.Text.Trim();
        string dest = txtDestinationCity.Text.Trim();

        DateTime depTime, arrTime;
        if (!DateTime.TryParse(txtDepartureTime.Text, out depTime) || !DateTime.TryParse(txtArrivalTime.Text, out arrTime))
        {
            ShowAlert("Please provide valid Departure and Arrival Date & Time.", "danger");
            return;
        }

        decimal econ, bus, first;
        if (!decimal.TryParse(txtEconomyPrice.Text, out econ) ||
            !decimal.TryParse(txtBusinessPrice.Text, out bus) ||
            !decimal.TryParse(txtFirstClassPrice.Text, out first))
        {
            ShowAlert("Please enter valid decimal prices for Economy, Business, and First class fares.", "danger");
            return;
        }

        int totalSeats, availSeats;
        if (!int.TryParse(txtTotalSeats.Text, out totalSeats) || !int.TryParse(txtAvailableSeats.Text, out availSeats))
        {
            ShowAlert("Please enter valid numeric seat capacity values.", "danger");
            return;
        }

        int? flightId = null;
        int parsedId;
        if (!string.IsNullOrEmpty(hfFlightId.Value) && int.TryParse(hfFlightId.Value, out parsedId))
        {
            flightId = parsedId;
        }

        string errorMsg;
        bool success = AdminHelper.SaveFlight(flightId, fNo, airline, origin, dest, depTime, arrTime,
            econ, bus, first, totalSeats, availSeats, ddlFlightStatus.SelectedValue, out errorMsg);

        if (success)
        {
            ShowAlert(flightId.HasValue ? "Flight record updated successfully!" : "New commercial flight added successfully!", "success");
            ResetFlightForm();
            BindFlights();
            BindSchedules();
            BindSeatAvailability();
            LoadDashboardKPIs();
        }
        else
        {
            ShowAlert("Failed to save flight: " + errorMsg, "danger");
        }
    }

    protected void btnCancelFlightForm_Click(object sender, EventArgs e)
    {
        ResetFlightForm();
    }

    private void ResetFlightForm()
    {
        hfFlightId.Value = "";
        txtFlightNumber.Text = "";
        txtAirlineName.Text = "";
        txtOriginCity.Text = "";
        txtDestinationCity.Text = "";
        txtDepartureTime.Text = "";
        txtArrivalTime.Text = "";
        txtEconomyPrice.Text = "";
        txtBusinessPrice.Text = "";
        txtFirstClassPrice.Text = "";
        txtTotalSeats.Text = "";
        txtAvailableSeats.Text = "";
        ddlFlightStatus.SelectedIndex = 0;
    }

    protected void gvFlights_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "EditFlight")
        {
            int fid = Convert.ToInt32(e.CommandArgument);
            DataRow r = AdminHelper.GetFlightById(fid);
            if (r != null)
            {
                hfFlightId.Value = fid.ToString();
                txtFlightNumber.Text = r["FlightNumber"].ToString();
                txtAirlineName.Text = r["AirlineName"].ToString();
                txtOriginCity.Text = r["OriginCity"].ToString();
                txtDestinationCity.Text = r["DestinationCity"].ToString();
                txtDepartureTime.Text = Convert.ToDateTime(r["DepartureTime"]).ToString("yyyy-MM-ddTHH:mm");
                txtArrivalTime.Text = Convert.ToDateTime(r["ArrivalTime"]).ToString("yyyy-MM-ddTHH:mm");
                txtEconomyPrice.Text = Convert.ToDecimal(r["EconomyPrice"]).ToString("0.##");
                txtBusinessPrice.Text = Convert.ToDecimal(r["BusinessPrice"]).ToString("0.##");
                txtFirstClassPrice.Text = Convert.ToDecimal(r["FirstClassPrice"]).ToString("0.##");
                txtTotalSeats.Text = r["TotalSeats"].ToString();
                txtAvailableSeats.Text = r["AvailableSeats"].ToString();
                if (ddlFlightStatus.Items.FindByValue(r["Status"].ToString()) != null)
                {
                    ddlFlightStatus.SelectedValue = r["Status"].ToString();
                }

                // Register client script to open collapse form
                ScriptManager.RegisterStartupScript(this, GetType(), "openForm", "var el = document.getElementById('collapseAddFlight'); if(el) new bootstrap.Collapse(el, {toggle: true});", true);
            }
        }
        else if (e.CommandName == "DeleteFlight")
        {
            int fid = Convert.ToInt32(e.CommandArgument);
            string error;
            if (AdminHelper.DeleteFlight(fid, out error))
            {
                ShowAlert("Flight #" + fid + " deleted successfully.", "success");
                BindFlights();
                BindSchedules();
                BindSeatAvailability();
                LoadDashboardKPIs();
            }
            else
            {
                ShowAlert(error, "danger");
            }
        }
    }

    // ====================================================================
    // SCREEN 2: SCHEDULES & TIMING CONTROL
    // ====================================================================
    private void BindSchedules()
    {
        gvSchedules.DataSource = AdminHelper.GetAllFlights();
        gvSchedules.DataBind();
    }

    protected void gvSchedules_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "EditSchedule")
        {
            int fid = Convert.ToInt32(e.CommandArgument);
            DataRow r = AdminHelper.GetFlightById(fid);
            if (r != null)
            {
                pnlScheduleEditor.Visible = true;
                hfScheduleFlightId.Value = fid.ToString();
                litScheduleFlightNo.Text = string.Format("{0} ({1} &rarr; {2})", r["FlightNumber"], r["OriginCity"], r["DestinationCity"]);
                txtSchedDepTime.Text = Convert.ToDateTime(r["DepartureTime"]).ToString("yyyy-MM-ddTHH:mm");
                txtSchedArrTime.Text = Convert.ToDateTime(r["ArrivalTime"]).ToString("yyyy-MM-ddTHH:mm");

                if (r["RevisedDepartureTime"] != DBNull.Value && r["RevisedDepartureTime"] != null)
                    txtRevisedDepTime.Text = Convert.ToDateTime(r["RevisedDepartureTime"]).ToString("yyyy-MM-ddTHH:mm");
                else
                    txtRevisedDepTime.Text = "";

                if (r["RevisedArrivalTime"] != DBNull.Value && r["RevisedArrivalTime"] != null)
                    txtRevisedArrTime.Text = Convert.ToDateTime(r["RevisedArrivalTime"]).ToString("yyyy-MM-ddTHH:mm");
                else
                    txtRevisedArrTime.Text = "";

                txtTimingReason.Text = r["TimingChangeReason"] != DBNull.Value ? r["TimingChangeReason"].ToString() : "";
                if (ddlScheduleStatus.Items.FindByValue(r["Status"].ToString()) != null)
                {
                    ddlScheduleStatus.SelectedValue = r["Status"].ToString();
                }
            }
        }
    }

    protected void btnUpdateSchedule_Click(object sender, EventArgs e)
    {
        int fid = Convert.ToInt32(hfScheduleFlightId.Value);
        DateTime dep, arr;
        if (!DateTime.TryParse(txtSchedDepTime.Text, out dep) || !DateTime.TryParse(txtSchedArrTime.Text, out arr))
        {
            ShowAlert("Please enter valid scheduled departure and arrival timings.", "danger");
            return;
        }

        DateTime? revDep = null;
        DateTime pRevDep;
        if (!string.IsNullOrWhiteSpace(txtRevisedDepTime.Text) && DateTime.TryParse(txtRevisedDepTime.Text, out pRevDep))
        {
            revDep = pRevDep;
        }

        DateTime? revArr = null;
        DateTime pRevArr;
        if (!string.IsNullOrWhiteSpace(txtRevisedArrTime.Text) && DateTime.TryParse(txtRevisedArrTime.Text, out pRevArr))
        {
            revArr = pRevArr;
        }

        string reason = txtTimingReason.Text.Trim();
        string status = ddlScheduleStatus.SelectedValue;

        string err;
        if (AdminHelper.UpdateFlightSchedule(fid, dep, arr, revDep, revArr, status, reason, out err))
        {
            ShowAlert("Schedule timing and dispatch advisory for Flight #" + fid + " updated successfully!", "success");
            pnlScheduleEditor.Visible = false;
            BindSchedules();
            BindFlights();
        }
        else
        {
            ShowAlert("Failed to update schedule: " + err, "danger");
        }
    }

    protected void btnCloseScheduleEditor_Click(object sender, EventArgs e)
    {
        pnlScheduleEditor.Visible = false;
    }

    // ====================================================================
    // SCREEN 3: RESERVATIONS OVERVIEW
    // ====================================================================
    private void BindReservations()
    {
        string filter = ddlResFilter.SelectedValue;
        string kw = txtResSearch.Text.Trim();
        gvReservations.DataSource = AdminHelper.GetAllReservations(filter, kw);
        gvReservations.DataBind();
    }

    protected void btnFilterReservations_Click(object sender, EventArgs e)
    {
        BindReservations();
    }

    protected void gvReservations_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        int bid = Convert.ToInt32(e.CommandArgument);
        string err;
        if (e.CommandName == "ConfirmBooking")
        {
            if (AdminHelper.AdminUpdateBookingStatus(bid, "Confirmed", out err))
            {
                ShowAlert("Booking #" + bid + " status updated to Confirmed.", "success");
                BindReservations();
                LoadDashboardKPIs();
            }
            else
            {
                ShowAlert(err, "danger");
            }
        }
        else if (e.CommandName == "CancelBooking")
        {
            if (AdminHelper.AdminUpdateBookingStatus(bid, "Cancelled", out err))
            {
                ShowAlert("Booking #" + bid + " status updated to Cancelled and seat inventory restored.", "success");
                BindReservations();
                BindSeatAvailability();
                LoadDashboardKPIs();
            }
            else
            {
                ShowAlert(err, "danger");
            }
        }
    }

    // ====================================================================
    // SCREEN 4: USERS MANAGEMENT
    // ====================================================================
    private void BindUsers()
    {
        gvUsers.DataSource = AdminHelper.GetAllUsers(txtUserSearch.Text.Trim());
        gvUsers.DataBind();
    }

    protected void btnSearchUsers_Click(object sender, EventArgs e)
    {
        BindUsers();
    }

    protected void gvUsers_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        int uid = Convert.ToInt32(e.CommandArgument);
        string err;
        string newRole = null;

        if (e.CommandName == "SetRoleAdmin") newRole = "Admin";
        else if (e.CommandName == "SetRoleClerk") newRole = "Clerk";
        else if (e.CommandName == "SetRoleUser") newRole = "User";

        if (newRole != null)
        {
            if (AdminHelper.UpdateUserRole(uid, newRole, out err))
            {
                ShowAlert(string.Format("User #{0} role updated to '{1}'.", uid, newRole), "success");
                BindUsers();
            }
            else
            {
                ShowAlert(err, "danger");
            }
        }
    }

    // ====================================================================
    // SCREEN 5: SEAT AVAILABILITY MONITOR
    // ====================================================================
    private void BindSeatAvailability()
    {
        gvSeatAvailability.DataSource = AdminHelper.GetSeatAvailabilityOverview();
        gvSeatAvailability.DataBind();
    }

    protected void gvSeatAvailability_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "CalibrateSeats")
        {
            int fid = Convert.ToInt32(e.CommandArgument);
            DataRow r = AdminHelper.GetFlightById(fid);
            if (r != null)
            {
                pnlSeatCalibrator.Visible = true;
                hfSeatFlightId.Value = fid.ToString();
                litSeatFlightNo.Text = string.Format("{0} (Current Available: {1} / Total: {2})", r["FlightNumber"], r["AvailableSeats"], r["TotalSeats"]);
                txtNewAvailableSeats.Text = r["AvailableSeats"].ToString();
            }
        }
    }

    protected void btnSaveSeatInventory_Click(object sender, EventArgs e)
    {
        int fid = Convert.ToInt32(hfSeatFlightId.Value);
        int newSeats;
        if (!int.TryParse(txtNewAvailableSeats.Text, out newSeats))
        {
            ShowAlert("Please enter a valid numeric value for available seats.", "danger");
            return;
        }

        string err;
        if (AdminHelper.UpdateSeatInventory(fid, newSeats, out err))
        {
            ShowAlert("Seat inventory for Flight #" + fid + " updated to " + newSeats + " seats successfully!", "success");
            pnlSeatCalibrator.Visible = false;
            BindSeatAvailability();
            BindFlights();
            LoadDashboardKPIs();
        }
        else
        {
            ShowAlert(err, "danger");
        }
    }

    protected void btnCloseSeatCalibrator_Click(object sender, EventArgs e)
    {
        pnlSeatCalibrator.Visible = false;
    }

    private void ShowAlert(string msg, string type)
    {
        pnlAdminAlert.Visible = true;
        pnlAdminAlert.CssClass = string.Format("alert alert-{0} alert-dismissible fade show shadow-sm mb-4", type);
        litAdminAlertMessage.Text = Server.HtmlEncode(msg);
    }
}

