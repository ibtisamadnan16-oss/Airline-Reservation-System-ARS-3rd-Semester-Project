using System;
using System.Collections.Generic;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using AirlineReservationSystem;

public partial class User_SearchFlights : Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            DateTime tomorrow = DateTime.Today.AddDays(1);
            txtDepartureDate.Text = tomorrow.ToString("yyyy-MM-dd");
            txtReturnDate.Text = tomorrow.AddDays(3).ToString("yyyy-MM-dd");
            txtReturnDate.Attributes.Add("min", DateTime.Today.ToString("yyyy-MM-dd"));
            txtDepartureDate.Attributes.Add("min", DateTime.Today.ToString("yyyy-MM-dd"));

            if (!string.IsNullOrEmpty(Request.QueryString["origin"]))
            {
                txtOrigin.Text = Request.QueryString["origin"];
            }
            if (!string.IsNullOrEmpty(Request.QueryString["destination"]))
            {
                txtDestination.Text = Request.QueryString["destination"];
            }

            if (!string.IsNullOrEmpty(txtOrigin.Text) && !string.IsNullOrEmpty(txtDestination.Text))
            {
                PerformFlightSearch();
            }
        }
    }

    protected void ddlTripType_SelectedIndexChanged(object sender, EventArgs e)
    {
        bool isRoundTrip = ddlTripType.SelectedValue == "RoundTrip";
        txtReturnDate.Enabled = isRoundTrip;
        if (isRoundTrip && string.IsNullOrEmpty(txtReturnDate.Text))
        {
            DateTime depDate;
            if (DateTime.TryParse(txtDepartureDate.Text, out depDate))
            {
                txtReturnDate.Text = depDate.AddDays(3).ToString("yyyy-MM-dd");
            }
            else
            {
                txtReturnDate.Text = DateTime.Today.AddDays(4).ToString("yyyy-MM-dd");
            }
        }
    }

    protected void btnSearchFlights_Click(object sender, EventArgs e)
    {
        PerformFlightSearch();
    }

    private void PerformFlightSearch()
    {
        pnlAlert.Visible = false;
        pnlAmbiguity.Visible = false;
        pnlNearestService.Visible = false;
        pnlDirectResults.Visible = false;
        pnlConnectingResults.Visible = false;
        pnlNoFlightsFound.Visible = false;

        string origin = txtOrigin.Text.Trim();
        string destination = txtDestination.Text.Trim();

        if (string.IsNullOrEmpty(origin) || string.IsNullOrEmpty(destination))
        {
            ShowError("Please specify both an Origin City and a Destination City.");
            return;
        }

        if (origin.Equals(destination, StringComparison.OrdinalIgnoreCase))
        {
            ShowError("Invalid Route: Origin City and Destination City cannot be the same.");
            return;
        }

        int adults = 1;
        if (!int.TryParse(txtAdults.Text.Trim(), out adults) || adults < 1)
        {
            ShowError("At least one adult passenger (12+ yrs) is required to book a flight.");
            return;
        }

        DateTime depDate;
        if (!DateTime.TryParse(txtDepartureDate.Text.Trim(), out depDate))
        {
            ShowError("Please select a valid Departure Date.");
            return;
        }

        bool isRoundTrip = ddlTripType.SelectedValue == "RoundTrip";
        DateTime? retDate = null;
        if (isRoundTrip)
        {
            DateTime rDate;
            if (!DateTime.TryParse(txtReturnDate.Text.Trim(), out rDate))
            {
                ShowError("Return Date is required for a Round-Trip journey.");
                return;
            }
            retDate = rDate;
        }

        string dateError;
        if (!FlightSearchHelper.ValidateDates(depDate, isRoundTrip, retDate, out dateError))
        {
            ShowError(dateError);
            return;
        }

        List<CityInfo> originMatches = FlightSearchHelper.LookupCity(origin);
        if (originMatches.Count > 1)
        {
            ViewState["AmbiguityTarget"] = "Origin";
            litAmbiguousCityName.Text = Server.HtmlEncode(origin);
            rptAmbiguousCandidates.DataSource = originMatches;
            rptAmbiguousCandidates.DataBind();
            pnlAmbiguity.Visible = true;
            return;
        }

        List<CityInfo> destMatches = FlightSearchHelper.LookupCity(destination);
        if (destMatches.Count > 1)
        {
            ViewState["AmbiguityTarget"] = "Destination";
            litAmbiguousCityName.Text = Server.HtmlEncode(destination);
            rptAmbiguousCandidates.DataSource = destMatches;
            rptAmbiguousCandidates.DataBind();
            pnlAmbiguity.Visible = true;
            return;
        }

        if (originMatches.Count == 1 && !originMatches[0].IsDirectlyServiced)
        {
            CityInfo c = originMatches[0];
            litNearestNotice.Text = string.Format(
                "AeroFly does not currently operate direct service to <strong>{0}</strong>. " +
                "Per Section 3.3.1, the nearest serviced airport is <strong>{1} ({2})</strong>, located approximately <strong>{3} km</strong> away.",
                Server.HtmlEncode(c.CityName), Server.HtmlEncode(c.NearestServicedCity), c.NearestAirportCode, c.DistanceToNearestKm);
            ViewState["NearestCityTarget"] = "Origin|" + c.NearestServicedCity;
            btnApplyNearestCity.Text = "Switch Origin to " + c.NearestServicedCity;
            pnlNearestService.Visible = true;
            return;
        }

        if (destMatches.Count == 1 && !destMatches[0].IsDirectlyServiced)
        {
            CityInfo c = destMatches[0];
            litNearestNotice.Text = string.Format(
                "AeroFly does not currently operate direct service to <strong>{0}</strong>. " +
                "Per Section 3.3.1, the nearest serviced airport is <strong>{1} ({2})</strong>, located approximately <strong>{3} km</strong> away.",
                Server.HtmlEncode(c.CityName), Server.HtmlEncode(c.NearestServicedCity), c.NearestAirportCode, c.DistanceToNearestKm);
            ViewState["NearestCityTarget"] = "Destination|" + c.NearestServicedCity;
            btnApplyNearestCity.Text = "Switch Destination to " + c.NearestServicedCity;
            pnlNearestService.Visible = true;
            return;
        }

        int childCount = 0;
        int.TryParse(txtChildren.Text.Trim(), out childCount);
        int seniorCount = 0;
        int.TryParse(txtSeniors.Text.Trim(), out seniorCount);

        string redirectUrl = string.Format(
            "~/~/Public/FlightResults.aspx?origin={0}&dest={1}&trip={2}&dep={3}&ret={4}&class={5}&adults={6}&children={7}&seniors={8}",
            Server.UrlEncode(origin),
            Server.UrlEncode(destination),
            Server.UrlEncode(ddlTripType.SelectedValue),
            Server.UrlEncode(depDate.ToString("yyyy-MM-dd")),
            Server.UrlEncode(retDate.HasValue ? retDate.Value.ToString("yyyy-MM-dd") : ""),
            Server.UrlEncode(ddlTravelClass.SelectedValue),
            adults,
            childCount,
            seniorCount);

        Response.Redirect(redirectUrl);
    }

    protected void rptAmbiguousCandidates_ItemCommand(object source, RepeaterCommandEventArgs e)
    {
        if (e.CommandName == "SelectCity")
        {
            string[] parts = e.CommandArgument.ToString().Split('|');
            string cityName = parts[0];
            string qualifiedName = parts.Length > 1 ? parts[1] : cityName;

            string target = ViewState["AmbiguityTarget"] != null ? ViewState["AmbiguityTarget"].ToString() : "Origin";
            if (target == "Origin")
            {
                txtOrigin.Text = cityName;
            }
            else
            {
                txtDestination.Text = cityName;
            }

            pnlAmbiguity.Visible = false;
            PerformFlightSearch();
        }
    }

    protected void btnApplyNearestCity_Click(object sender, EventArgs e)
    {
        if (ViewState["NearestCityTarget"] != null)
        {
            string[] parts = ViewState["NearestCityTarget"].ToString().Split('|');
            string target = parts[0];
            string nearestCity = parts[1];

            if (target == "Origin")
            {
                txtOrigin.Text = nearestCity;
            }
            else
            {
                txtDestination.Text = nearestCity;
            }

            pnlNearestService.Visible = false;
            PerformFlightSearch();
        }
    }

    private void ShowError(string msg)
    {
        pnlAlert.Visible = true;
        litAlertMsg.Text = msg;
    }
}

