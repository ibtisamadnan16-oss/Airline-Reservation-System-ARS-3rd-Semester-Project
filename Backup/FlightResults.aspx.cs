using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using AirlineReservationSystem;

public partial class FlightResults : Page
{
    public string OriginCity { get { return ViewState["Origin"] != null ? ViewState["Origin"].ToString() : "Karachi"; } set { ViewState["Origin"] = value; } }
    public string DestinationCity { get { return ViewState["Dest"] != null ? ViewState["Dest"].ToString() : "Islamabad"; } set { ViewState["Dest"] = value; } }
    public string TripType { get { return ViewState["TripType"] != null ? ViewState["TripType"].ToString() : "OneWay"; } set { ViewState["TripType"] = value; } }
    public string TravelClass { get { return ViewState["TravelClass"] != null ? ViewState["TravelClass"].ToString() : "Economy_NonSmoking"; } set { ViewState["TravelClass"] = value; } }
    public string DepartureDateStr { get { return ViewState["DepDate"] != null ? ViewState["DepDate"].ToString() : DateTime.Today.AddDays(1).ToString("yyyy-MM-dd"); } set { ViewState["DepDate"] = value; } }
    public string ReturnDateStr { get { return ViewState["RetDate"] != null ? ViewState["RetDate"].ToString() : DateTime.Today.AddDays(3).ToString("yyyy-MM-dd"); } set { ViewState["RetDate"] = value; } }
    
    public int Adults { get { return ViewState["Adults"] != null ? Convert.ToInt32(ViewState["Adults"]) : 1; } set { ViewState["Adults"] = value; } }
    public int Children { get { return ViewState["Children"] != null ? Convert.ToInt32(ViewState["Children"]) : 0; } set { ViewState["Children"] = value; } }
    public int Seniors { get { return ViewState["Seniors"] != null ? Convert.ToInt32(ViewState["Seniors"]) : 0; } set { ViewState["Seniors"] = value; } }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            ReadSearchParameters();
            DisplaySearchSummary();
            LoadOnwardFlights();

            if (TripType == "RoundTrip")
            {
                pnlReturnSection.Visible = true;
                phReturnDateSummary.Visible = true;
                LoadReturnFlights();
            }
            else
            {
                pnlReturnSection.Visible = false;
                phReturnDateSummary.Visible = false;
            }

            UpdateTotalFare();
        }
    }

    private void ReadSearchParameters()
    {
        if (!string.IsNullOrEmpty(Request.QueryString["origin"])) OriginCity = Request.QueryString["origin"];
        if (!string.IsNullOrEmpty(Request.QueryString["dest"])) DestinationCity = Request.QueryString["dest"];
        if (!string.IsNullOrEmpty(Request.QueryString["trip"])) TripType = Request.QueryString["trip"];
        if (!string.IsNullOrEmpty(Request.QueryString["dep"])) DepartureDateStr = Request.QueryString["dep"];
        if (!string.IsNullOrEmpty(Request.QueryString["ret"])) ReturnDateStr = Request.QueryString["ret"];
        if (!string.IsNullOrEmpty(Request.QueryString["class"])) TravelClass = Request.QueryString["class"];

        int a;
        if (int.TryParse(Request.QueryString["adults"], out a) && a >= 1) Adults = a;
        int c;
        if (int.TryParse(Request.QueryString["children"], out c)) Children = c;
        int s;
        if (int.TryParse(Request.QueryString["seniors"], out s)) Seniors = s;
    }

    private void DisplaySearchSummary()
    {
        litOriginCity.Text = Server.HtmlEncode(OriginCity);
        litDestinationCity.Text = Server.HtmlEncode(DestinationCity);
        litTripTypeBadge.Text = TripType == "RoundTrip" ? "Round-Trip Journey" : "One-Way Journey";

        // Format Class Name nicely
        string formattedClass = TravelClass.Replace("_", " ");
        litClassBadge.Text = formattedClass;

        DateTime depDate;
        if (DateTime.TryParse(DepartureDateStr, out depDate))
        {
            litDepDateDisplay.Text = depDate.ToString("ddd, dd MMM yyyy");
            litOnwardDateTitle.Text = depDate.ToString("dd MMM yyyy");
        }
        else
        {
            litDepDateDisplay.Text = DepartureDateStr;
            litOnwardDateTitle.Text = DepartureDateStr;
        }

        litOnwardRouteTitle.Text = Server.HtmlEncode(OriginCity + " \u2192 " + DestinationCity);

        if (TripType == "RoundTrip")
        {
            DateTime retDate;
            if (DateTime.TryParse(ReturnDateStr, out retDate))
            {
                litRetDateDisplay.Text = retDate.ToString("ddd, dd MMM yyyy");
                litReturnDateTitle.Text = retDate.ToString("dd MMM yyyy");
            }
            else
            {
                litRetDateDisplay.Text = ReturnDateStr;
                litReturnDateTitle.Text = ReturnDateStr;
            }
            litReturnRouteTitle.Text = Server.HtmlEncode(DestinationCity + " \u2192 " + OriginCity);
        }

        litPassengerSummary.Text = string.Format("{0} Adult(s){1}{2}",
            Adults,
            Children > 0 ? ", " + Children + " Child(ren)" : "",
            Seniors > 0 ? ", " + Seniors + " Senior(s)" : "");
    }

    private void LoadOnwardFlights()
    {
        DateTime depDate;
        DateTime? dtFilter = DateTime.TryParse(DepartureDateStr, out depDate) ? (DateTime?)depDate : null;

        DataTable dt = FlightSearchHelper.SearchDirectFlights(OriginCity, DestinationCity, dtFilter);
        if (dt != null && dt.Rows.Count > 0)
        {
            litOnwardCount.Text = dt.Rows.Count.ToString();
            rptOnwardFlights.DataSource = dt;
            rptOnwardFlights.DataBind();
            pnlNoOnward.Visible = false;

            // Auto-select first flight if none selected
            if (ViewState["SelectedOnwardId"] == null)
            {
                DataRow r0 = dt.Rows[0];
                SelectOnwardFlight(r0["FlightId"].ToString(), r0["FlightNumber"].ToString(), Convert.ToDecimal(r0["EconomyPrice"]), r0["DepartureTime"].ToString(), r0["ArrivalTime"].ToString());
            }
        }
        else
        {
            litOnwardCount.Text = "0";
            rptOnwardFlights.DataSource = null;
            rptOnwardFlights.DataBind();
            pnlNoOnward.Visible = true;
        }
    }

    private void LoadReturnFlights()
    {
        DateTime retDate;
        DateTime? dtFilter = DateTime.TryParse(ReturnDateStr, out retDate) ? (DateTime?)retDate : null;

        // Return route: Destination -> Origin
        DataTable dt = FlightSearchHelper.SearchDirectFlights(DestinationCity, OriginCity, dtFilter);
        if (dt != null && dt.Rows.Count > 0)
        {
            litReturnCount.Text = dt.Rows.Count.ToString();
            rptReturnFlights.DataSource = dt;
            rptReturnFlights.DataBind();
            pnlNoReturn.Visible = false;

            // Auto-select first return flight if none selected
            if (ViewState["SelectedReturnId"] == null)
            {
                DataRow r0 = dt.Rows[0];
                SelectReturnFlight(r0["FlightId"].ToString(), r0["FlightNumber"].ToString(), Convert.ToDecimal(r0["EconomyPrice"]), r0["DepartureTime"].ToString(), r0["ArrivalTime"].ToString());
            }
        }
        else
        {
            litReturnCount.Text = "0";
            rptReturnFlights.DataSource = null;
            rptReturnFlights.DataBind();
            pnlNoReturn.Visible = true;
        }
    }

    protected void rptOnwardFlights_ItemCommand(object source, RepeaterCommandEventArgs e)
    {
        if (e.CommandName == "SelectOnward")
        {
            string[] parts = e.CommandArgument.ToString().Split('|');
            string flightId = parts[0];
            string flightNum = parts[1];
            decimal price = Convert.ToDecimal(parts[2]);
            string depTime = parts[3];
            string arrTime = parts[4];

            SelectOnwardFlight(flightId, flightNum, price, depTime, arrTime);
            LoadOnwardFlights(); // Rebind to update selection highlight
            UpdateTotalFare();
        }
    }

    protected void rptReturnFlights_ItemCommand(object source, RepeaterCommandEventArgs e)
    {
        if (e.CommandName == "SelectReturn")
        {
            string[] parts = e.CommandArgument.ToString().Split('|');
            string flightId = parts[0];
            string flightNum = parts[1];
            decimal price = Convert.ToDecimal(parts[2]);
            string depTime = parts[3];
            string arrTime = parts[4];

            SelectReturnFlight(flightId, flightNum, price, depTime, arrTime);
            LoadReturnFlights(); // Rebind to update selection highlight
            UpdateTotalFare();
        }
    }

    private void SelectOnwardFlight(string flightId, string flightNum, decimal price, string depTime, string arrTime)
    {
        ViewState["SelectedOnwardId"] = flightId;
        ViewState["SelectedOnwardPrice"] = price;

        DateTime dtDep = Convert.ToDateTime(depTime);
        DateTime dtArr = Convert.ToDateTime(arrTime);

        litSelectedOnwardInfo.Text = string.Format(
            "<span class='text-primary fw-bold'>{0}</span> &bull; {1} &rarr; {2} ({3} - {4})<br/><small class='text-success fw-bold'>PKR {5:N0} / passenger</small>",
            flightNum, OriginCity, DestinationCity, dtDep.ToString("hh:mm tt"), dtArr.ToString("hh:mm tt"), price);
    }

    private void SelectReturnFlight(string flightId, string flightNum, decimal price, string depTime, string arrTime)
    {
        ViewState["SelectedReturnId"] = flightId;
        ViewState["SelectedReturnPrice"] = price;

        DateTime dtDep = Convert.ToDateTime(depTime);
        DateTime dtArr = Convert.ToDateTime(arrTime);

        litSelectedReturnInfo.Text = string.Format(
            "<span class='text-primary fw-bold'>{0}</span> &bull; {1} &rarr; {2} ({3} - {4})<br/><small class='text-success fw-bold'>PKR {5:N0} / passenger</small>",
            flightNum, DestinationCity, OriginCity, dtDep.ToString("hh:mm tt"), dtArr.ToString("hh:mm tt"), price);
    }

    private void UpdateTotalFare()
    {
        decimal onwardPrice = ViewState["SelectedOnwardPrice"] != null ? Convert.ToDecimal(ViewState["SelectedOnwardPrice"]) : 0;
        decimal returnPrice = (TripType == "RoundTrip" && ViewState["SelectedReturnPrice"] != null) ? Convert.ToDecimal(ViewState["SelectedReturnPrice"]) : 0;

        int totalPassengers = Adults + Children + Seniors;
        if (totalPassengers <= 0) totalPassengers = 1;

        // Children get 25% discount, Seniors get 15% discount standard in airline systems
        decimal total = 0;
        decimal baseFarePerPerson = onwardPrice + returnPrice;

        total += Adults * baseFarePerPerson;
        total += Children * (baseFarePerPerson * 0.75m);
        total += Seniors * (baseFarePerPerson * 0.85m);

        litGrandTotal.Text = string.Format("{0:N0}", total);
    }

    public bool IsOnwardSelected(object flightId)
    {
        if (ViewState["SelectedOnwardId"] == null || flightId == null) return false;
        return ViewState["SelectedOnwardId"].ToString() == flightId.ToString();
    }

    public bool IsReturnSelected(object flightId)
    {
        if (ViewState["SelectedReturnId"] == null || flightId == null) return false;
        return ViewState["SelectedReturnId"].ToString() == flightId.ToString();
    }

    public string FormatDuration(object depObj, object arrObj)
    {
        if (depObj == null || arrObj == null) return "N/A";
        DateTime dep = Convert.ToDateTime(depObj);
        DateTime arr = Convert.ToDateTime(arrObj);
        TimeSpan dur = arr - dep;

        int hours = (int)dur.TotalHours;
        int mins = dur.Minutes;

        if (mins > 0)
        {
            return string.Format("{0}h {1}m", hours, mins);
        }
        return string.Format("{0}h", hours);
    }

    protected void btnProceedBooking_Click(object sender, EventArgs e)
    {
        if (ViewState["SelectedOnwardId"] == null)
        {
            ShowAlert("Please select an onward flight first.");
            return;
        }

        if (TripType == "RoundTrip" && ViewState["SelectedReturnId"] == null)
        {
            ShowAlert("Please select a return flight for your round-trip journey.");
            return;
        }

        string url = string.Format(
            "~/ReservationReview.aspx?onwardId={0}&returnId={1}&class={2}&adults={3}&children={4}&seniors={5}&action=book",
            ViewState["SelectedOnwardId"],
            ViewState["SelectedReturnId"] != null ? ViewState["SelectedReturnId"] : "0",
            Server.UrlEncode(TravelClass),
            Adults,
            Children,
            Seniors);

        Response.Redirect(url);
    }

    protected void btnBlockSeat_Click(object sender, EventArgs e)
    {
        if (ViewState["SelectedOnwardId"] == null)
        {
            ShowAlert("Please select a flight to block seats.");
            return;
        }

        string url = string.Format(
            "~/ReservationReview.aspx?onwardId={0}&returnId={1}&class={2}&adults={3}&children={4}&seniors={5}&action=block",
            ViewState["SelectedOnwardId"],
            ViewState["SelectedReturnId"] != null ? ViewState["SelectedReturnId"] : "0",
            Server.UrlEncode(TravelClass),
            Adults,
            Children,
            Seniors);

        Response.Redirect(url);
    }

    private void ShowAlert(string msg)
    {
        pnlAlert.Visible = true;
        litAlertMsg.Text = msg;
    }
}
