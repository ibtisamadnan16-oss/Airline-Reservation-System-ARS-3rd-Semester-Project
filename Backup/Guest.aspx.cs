using System;
using System.Data;
using System.Web.UI;
using AirlineReservationSystem;

public partial class Guest : Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        // Explicitly set guest state if not logged in
        if (!UserStateHelper.IsLoggedIn)
        {
            UserStateHelper.SetGuest();
        }

        if (!IsPostBack)
        {
            LoadFlights();
        }
    }

    private void LoadFlights()
    {
        try
        {
            string query = "SELECT FlightId, FlightNumber, AirlineName, OriginCity, DestinationCity, DepartureTime, ArrivalTime, EconomyPrice, BusinessPrice, AvailableSeats FROM Flights WHERE AvailableSeats > 0 ORDER BY DepartureTime ASC";
            DataTable dt = DbHelper.ExecuteQuery(query);
            rptGuestFlights.DataSource = dt;
            rptGuestFlights.DataBind();
        }
        catch (Exception ex)
        {
            // Log or show error
        }
    }
}
