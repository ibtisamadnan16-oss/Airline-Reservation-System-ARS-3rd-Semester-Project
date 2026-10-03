using System;
using System.Web.UI;
using AirlineReservationSystem;

public partial class Admin_SeatAvailability : Page
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
            gvSeatAvailability.DataSource = AdminHelper.GetSeatAvailabilityOverview();
            gvSeatAvailability.DataBind();
        }
    }

    protected string GetProgressBar(object totalObj, object availObj)
    {
        int total = Convert.ToInt32(totalObj);
        int avail = Convert.ToInt32(availObj);
        if (total <= 0) return "<div class='text-muted small'>N/A</div>";

        int occupied = total - avail;
        int pct = (int)Math.Round(((double)occupied / total) * 100);
        string barColor = pct > 85 ? "bg-danger" : (pct > 60 ? "bg-warning" : "bg-success");

        return string.Format(
            "<div class='progress' style='height: 12px;'>" +
            "<div class='progress-bar {0}' role='progressbar' style='width: {1}%;' aria-valuenow='{1}' aria-valuemin='0' aria-valuemax='100'></div>" +
            "</div><small class='text-muted'>{1}% occupied ({2} booked)</small>",
            barColor, pct, occupied);
    }
}
