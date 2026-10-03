using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using AirlineReservationSystem;

public partial class Admin_Flights : Page
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
            Response.Redirect("~/User/Dashboard.aspx");
            return;
        }

        if (!IsPostBack)
        {
            txtDepartureTime.Text = DateTime.Now.AddDays(5).ToString("yyyy-MM-ddTHH:mm");
            txtArrivalTime.Text = DateTime.Now.AddDays(5).AddHours(2).ToString("yyyy-MM-ddTHH:mm");
            BindFlights();
        }
    }

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

        decimal econ, bus;
        int seats;
        if (!decimal.TryParse(txtEconomyPrice.Text, out econ) || !decimal.TryParse(txtBusinessPrice.Text, out bus) || !int.TryParse(txtSeats.Text, out seats))
        {
            ShowAlert("Please check pricing and capacity values.", "danger");
            return;
        }

        string err;
        bool ok = AdminHelper.SaveFlight(null, fNo, airline, origin, dest, depTime, arrTime, econ, bus, bus * 1.5m, seats, seats, "Active", out err);
        if (ok)
        {
            ShowAlert("Commercial Flight " + fNo + " successfully registered!", "success");
            BindFlights();
        }
        else
        {
            ShowAlert("Could not register flight: " + err, "danger");
        }
    }

    protected void gvFlights_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        int flightId = Convert.ToInt32(e.CommandArgument);
        if (e.CommandName == "ToggleStatus")
        {
            DataRow r = AdminHelper.GetFlightById(flightId);
            if (r != null)
            {
                string currStatus = r["Status"].ToString();
                string newStatus = currStatus.Equals("Active", StringComparison.OrdinalIgnoreCase) ? "Inactive" : "Active";
                string err;
                AdminHelper.SaveFlight(flightId, r["FlightNumber"].ToString(), r["AirlineName"].ToString(),
                    r["OriginCity"].ToString(), r["DestinationCity"].ToString(),
                    Convert.ToDateTime(r["DepartureTime"]), Convert.ToDateTime(r["ArrivalTime"]),
                    Convert.ToDecimal(r["EconomyPrice"]), Convert.ToDecimal(r["BusinessPrice"]), Convert.ToDecimal(r["FirstClassPrice"]),
                    Convert.ToInt32(r["TotalSeats"]), Convert.ToInt32(r["AvailableSeats"]), newStatus, out err);
                ShowAlert("Flight status updated to " + newStatus, "info");
                BindFlights();
            }
        }
        else if (e.CommandName == "DeleteFlight")
        {
            string err;
            if (AdminHelper.DeleteFlight(flightId, out err))
            {
                ShowAlert("Flight removed from schedules.", "warning");
                BindFlights();
            }
            else
            {
                ShowAlert(err, "danger");
            }
        }
    }

    private void ShowAlert(string msg, string type)
    {
        pnlAlert.Visible = true;
        pnlAlert.CssClass = "alert alert-" + type + " alert-dismissible fade show";
        litAlertMsg.Text = msg;
    }
}
