using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using AirlineReservationSystem;

public partial class User_MyTickets : Page
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
            LoadMyBookings();
        }
    }

    private void LoadMyBookings()
    {
        try
        {
            string query = @"
                SELECT b.BookingId, b.ConfirmationNumber, b.TravelClass, b.PassengerCount, b.TotalPrice, b.Status, b.BookingDate,
                       f.FlightNumber, f.OriginCity, f.DestinationCity, f.DepartureTime, f.ArrivalTime
                FROM Bookings b
                INNER JOIN Flights f ON b.FlightId = f.FlightId
                WHERE b.UserId = @UserId
                ORDER BY b.BookingDate DESC";

            SqlParameter[] parameters = new SqlParameter[]
            {
                new SqlParameter("@UserId", UserStateHelper.CurrentUserId)
            };

            DataTable dt = DbHelper.ExecuteQuery(query, parameters);
            if (dt.Rows.Count > 0)
            {
                rptBookings.DataSource = dt;
                rptBookings.DataBind();
                pnlAlert.Visible = false;
            }
            else
            {
                pnlAlert.Visible = true;
                pnlAlert.CssClass = "alert alert-info";
                litAlertMsg.Text = "You have no active or past bookings. Click <strong>Book New Flight</strong> to schedule your first trip!";
            }
        }
        catch (Exception ex)
        {
            pnlAlert.Visible = true;
            pnlAlert.CssClass = "alert alert-danger";
            litAlertMsg.Text = "Error loading your tickets: " + ex.Message;
        }
    }

    protected string GetStatusBadgeClass(string status)
    {
        switch (status.ToLower())
        {
            case "confirmed": return "bg-success";
            case "blocked": return "bg-warning text-dark";
            case "cancelled": return "bg-danger";
            default: return "bg-secondary";
        }
    }

    protected string GetActionButtons(string code, string status)
    {
        if (status.Equals("Blocked", StringComparison.OrdinalIgnoreCase))
        {
            return string.Format("<a href='{0}' class='btn btn-sm btn-warning' title='Confirm Blocked Ticket'><i class='fa-solid fa-circle-check'></i></a>",
                ResolveUrl("~/User/ConfirmTicket.aspx?blk=" + code));
        }
        else if (status.Equals("Confirmed", StringComparison.OrdinalIgnoreCase))
        {
            return string.Format("<a href='{0}' class='btn btn-sm btn-info text-white me-1' title='Reschedule'><i class='fa-solid fa-arrows-rotate'></i></a><a href='{1}' class='btn btn-sm btn-outline-danger' title='Cancel'><i class='fa-solid fa-xmark'></i></a>",
                ResolveUrl("~/User/RescheduleTicket.aspx?cnf=" + code),
                ResolveUrl("~/User/CancelTicket.aspx?cnf=" + code));
        }
        return "";
    }
}
