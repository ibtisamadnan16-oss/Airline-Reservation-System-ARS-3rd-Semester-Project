using System;
using System.Web.UI;
using AirlineReservationSystem;

public partial class Logout : Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        UserStateHelper.Logout();
        Response.Redirect("~/Login.aspx?msg=logged_out");
    }
}
