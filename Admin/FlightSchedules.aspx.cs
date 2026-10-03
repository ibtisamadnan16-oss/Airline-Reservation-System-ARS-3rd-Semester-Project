using System;
using System.Data;
using System.Web.UI;
using AirlineReservationSystem;

public partial class Admin_FlightSchedules : Page
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
            LoadFlightsDropdown();
            BindSchedules();
        }
    }

    private void LoadFlightsDropdown()
    {
        DataTable dt = AdminHelper.GetAllFlights();
        ddlScheduleFlight.Items.Clear();
        foreach (DataRow r in dt.Rows)
        {
            string text = string.Format("{0} - {1} to {2}", r["FlightNumber"], r["OriginCity"], r["DestinationCity"]);
            ddlScheduleFlight.Items.Add(new System.Web.UI.WebControls.ListItem(text, r["FlightId"].ToString()));
        }
        if (ddlScheduleFlight.Items.Count > 0)
        {
            PopulateFlightTimes(Convert.ToInt32(ddlScheduleFlight.SelectedValue));
        }
    }

    protected void ddlScheduleFlight_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (!string.IsNullOrEmpty(ddlScheduleFlight.SelectedValue))
        {
            PopulateFlightTimes(Convert.ToInt32(ddlScheduleFlight.SelectedValue));
        }
    }

    private void PopulateFlightTimes(int flightId)
    {
        DataTable dt = DbHelper.ExecuteQuery("SELECT DepartureTime, ArrivalTime FROM Flights WHERE FlightId = " + flightId);
        if (dt.Rows.Count > 0)
        {
            DateTime dep = Convert.ToDateTime(dt.Rows[0]["DepartureTime"]);
            DateTime arr = Convert.ToDateTime(dt.Rows[0]["ArrivalTime"]);
            txtNewDepTime.Text = dep.ToString("yyyy-MM-ddTHH:mm");
            txtNewArrTime.Text = arr.ToString("yyyy-MM-ddTHH:mm");
        }
    }

    private void BindSchedules()
    {
        gvSchedules.DataSource = AdminHelper.GetAllFlights();
        gvSchedules.DataBind();
    }

    protected void btnUpdateSchedule_Click(object sender, EventArgs e)
    {
        int flightId = Convert.ToInt32(ddlScheduleFlight.SelectedValue);
        DateTime depTime, arrTime;
        if (!DateTime.TryParse(txtNewDepTime.Text, out depTime) || !DateTime.TryParse(txtNewArrTime.Text, out arrTime))
        {
            ShowAlert("Please specify valid departure and arrival timestamps.", "danger");
            return;
        }

        string reason = txtDelayReason.Text.Trim();
        string status = ddlFlightStatus.SelectedValue;
        string err;
        bool ok = AdminHelper.UpdateFlightSchedule(flightId, depTime, arrTime, null, null, status, reason, out err);
        if (ok)
        {
            ShowAlert("Flight schedule adjusted and advisory updated successfully!", "success");
            BindSchedules();
        }
        else
        {
            ShowAlert("Failed to update schedule: " + err, "danger");
        }
    }

    private void ShowAlert(string msg, string type)
    {
        pnlAlert.Visible = true;
        pnlAlert.CssClass = "alert alert-" + type + " alert-dismissible fade show";
        litAlertMsg.Text = msg;
    }
}
