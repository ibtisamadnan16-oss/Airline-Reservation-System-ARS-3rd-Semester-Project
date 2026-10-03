using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using AirlineReservationSystem;

public partial class Public_Home : Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadAvailableFlights();
        }
    }

    private void LoadAvailableFlights(string origin = "", string destination = "")
    {
        try
        {
            string query = "SELECT FlightId, FlightNumber, AirlineName, OriginCity, DestinationCity, DepartureTime, ArrivalTime, EconomyPrice, BusinessPrice, FirstClassPrice, AvailableSeats, Status FROM Flights WHERE AvailableSeats > 0";

            SqlParameter[] parameters = null;

            if (!string.IsNullOrEmpty(origin) && !string.IsNullOrEmpty(destination))
            {
                query += " AND OriginCity = @Origin AND DestinationCity = @Destination";
                parameters = new SqlParameter[]
                {
                    new SqlParameter("@Origin", origin),
                    new SqlParameter("@Destination", destination)
                };
            }
            else if (!string.IsNullOrEmpty(origin))
            {
                query += " AND OriginCity = @Origin";
                parameters = new SqlParameter[] { new SqlParameter("@Origin", origin) };
            }
            else if (!string.IsNullOrEmpty(destination))
            {
                query += " AND DestinationCity = @Destination";
                parameters = new SqlParameter[] { new SqlParameter("@Destination", destination) };
            }

            query += " ORDER BY DepartureTime ASC";

            DataTable dt = DbHelper.ExecuteQuery(query, parameters);
            if (dt.Rows.Count > 0)
            {
                pnlResults.Visible = true;
                rptFlights.DataSource = dt;
                rptFlights.DataBind();
                pnlSearchAlert.Visible = false;
            }
            else
            {
                pnlResults.Visible = false;
                pnlSearchAlert.Visible = true;
                pnlSearchAlert.CssClass = "alert alert-warning";
                litSearchAlert.Text = "<strong>No direct flights found</strong> for the selected route. In Phase 2, our route selection algorithm will suggest connecting flights and nearest service cities per Section 3.3.1.";
            }
        }
        catch (Exception ex)
        {
            pnlSearchAlert.Visible = true;
            pnlSearchAlert.CssClass = "alert alert-danger";
            litSearchAlert.Text = "<strong>Database Error:</strong> " + Server.HtmlEncode(ex.Message);
        }
    }

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        string origin = ddlOrigin.SelectedValue;
        string destination = ddlDestination.SelectedValue;

        if (!string.IsNullOrEmpty(origin) && !string.IsNullOrEmpty(destination) && origin.Equals(destination, StringComparison.OrdinalIgnoreCase))
        {
            pnlSearchAlert.Visible = true;
            pnlSearchAlert.CssClass = "alert alert-warning";
            litSearchAlert.Text = "<strong>Invalid Selection:</strong> Origin and Destination cities cannot be the same.";
            pnlResults.Visible = false;
            return;
        }

        LoadAvailableFlights(origin, destination);
    }
}

