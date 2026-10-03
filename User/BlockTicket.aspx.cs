using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using AirlineReservationSystem;

public partial class User_BlockTicket : Page
{
    public int OnwardFlightId { get { return ViewState["OnwardId"] != null ? Convert.ToInt32(ViewState["OnwardId"]) : 0; } set { ViewState["OnwardId"] = value; } }
    public int ReturnFlightId { get { return ViewState["ReturnId"] != null ? Convert.ToInt32(ViewState["ReturnId"]) : 0; } set { ViewState["ReturnId"] = value; } }
    public string TravelClass { get { return ViewState["TravelClass"] != null ? ViewState["TravelClass"].ToString() : "Economy_NonSmoking"; } set { ViewState["TravelClass"] = value; } }

    public int Adults { get { return ViewState["Adults"] != null ? Convert.ToInt32(ViewState["Adults"]) : 1; } set { ViewState["Adults"] = value; } }
    public int Children { get { return ViewState["Children"] != null ? Convert.ToInt32(ViewState["Children"]) : 0; } set { ViewState["Children"] = value; } }
    public int Seniors { get { return ViewState["Seniors"] != null ? Convert.ToInt32(ViewState["Seniors"]) : 0; } set { ViewState["Seniors"] = value; } }

    public decimal CalculatedGrandTotal { get { return ViewState["GrandTotal"] != null ? Convert.ToDecimal(ViewState["GrandTotal"]) : 0; } set { ViewState["GrandTotal"] = value; } }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            ReadParameters();
            LoadFlightDetails();
            PreFillUserData();
            CalculateAndDisplayPricing();
            LoadCancellationPolicies();
        }
    }

    private void ReadParameters()
    {
        int onwId;
        if (int.TryParse(Request.QueryString["onwardId"], out onwId)) OnwardFlightId = onwId;

        int retId;
        if (int.TryParse(Request.QueryString["returnId"], out retId)) ReturnFlightId = retId;

        if (!string.IsNullOrEmpty(Request.QueryString["class"])) TravelClass = Request.QueryString["class"];

        int a;
        if (int.TryParse(Request.QueryString["adults"], out a) && a >= 1) Adults = a;
        int c;
        if (int.TryParse(Request.QueryString["children"], out c)) Children = c;
        int s;
        if (int.TryParse(Request.QueryString["seniors"], out s)) Seniors = s;
    }

    private void PreFillUserData()
    {
        if (UserStateHelper.IsLoggedIn)
        {
            int userId = UserStateHelper.CurrentUserId;
            string query = "SELECT FirstName, LastName, PhoneNumber, Email, PreferredCreditCard FROM Users WHERE UserId = @UserId";
            SqlParameter[] p = new SqlParameter[] { new SqlParameter("@UserId", userId) };
            DataTable dt = DbHelper.ExecuteQuery(query, p);
            if (dt.Rows.Count > 0)
            {
                DataRow r = dt.Rows[0];
                txtPassengerName.Text = r["FirstName"] + " " + r["LastName"];
                txtPhone.Text = r["PhoneNumber"].ToString();
                txtEmail.Text = r["Email"].ToString();
                txtCreditCard.Text = r["PreferredCreditCard"].ToString();
            }
        }
    }

    private void LoadFlightDetails()
    {
        if (OnwardFlightId <= 0)
        {
            OnwardFlightId = 1002;
        }

        litHeaderTripType.Text = ReturnFlightId > 0 ? "Round-Trip Journey" : "One-Way Journey";

        string query = "SELECT FlightId, FlightNumber, AirlineName, OriginCity, DestinationCity, DepartureTime, ArrivalTime, EconomyPrice, BusinessPrice, FirstClassPrice, AvailableSeats FROM Flights WHERE FlightId = @Id";
        DataTable dtOnward = DbHelper.ExecuteQuery(query, new SqlParameter[] { new SqlParameter("@Id", OnwardFlightId) });

        if (dtOnward.Rows.Count > 0)
        {
            DataRow r = dtOnward.Rows[0];
            litOnwardFlightNumber.Text = r["FlightNumber"].ToString();
            litOnwardAirline.Text = r["AirlineName"].ToString();
            litOnwardOrigin.Text = r["OriginCity"].ToString();
            litOnwardDest.Text = r["DestinationCity"].ToString();

            DateTime dtDep = Convert.ToDateTime(r["DepartureTime"]);
            DateTime dtArr = Convert.ToDateTime(r["ArrivalTime"]);

            litOnwardDepTime.Text = dtDep.ToString("hh:mm tt");
            litOnwardDepDate.Text = dtDep.ToString("ddd, dd MMM yyyy");
            litOnwardArrTime.Text = dtArr.ToString("hh:mm tt");
            litOnwardArrDate.Text = dtArr.ToString("ddd, dd MMM yyyy");

            TimeSpan dur = dtArr - dtDep;
            litOnwardDuration.Text = string.Format("{0}h{1}", (int)dur.TotalHours, dur.Minutes > 0 ? " " + dur.Minutes + "m" : "");
            litTravelClass.Text = TravelClass.Replace("_", " ");

            decimal onwardBaseFare = TravelClass.StartsWith("Business") ? Convert.ToDecimal(r["BusinessPrice"]) : Convert.ToDecimal(r["EconomyPrice"]);
            ViewState["OnwardBasePrice"] = onwardBaseFare;

            int daysUntilDeparture;
            string ruleExplanation;
            bool canBlock = ReservationHelper.CanBlockSeat(dtDep, out daysUntilDeparture, out ruleExplanation);
            ViewState["CanBlock"] = canBlock;

            if (canBlock)
            {
                btnBlockTicket.Enabled = true;
                btnBlockTicket.CssClass = "btn btn-warning text-dark py-2 fw-bold";
                pnlBlockingRuleNotice.CssClass = "alert alert-success p-2 small mb-3 text-start";
                litBlockingRuleNotice.Text = string.Format(
                    "<i class='fa-solid fa-circle-check text-success me-1'></i> <strong>Rule 2 Applied (Departure &gt; 14 days away):</strong> " +
                    "Flight departs in <strong>{0} days</strong>. Both <strong>[ Block Ticket ]</strong> and <strong>[ Buy Ticket ]</strong> are available.",
                    daysUntilDeparture);
            }
            else
            {
                btnBlockTicket.Enabled = false;
                btnBlockTicket.CssClass = "btn btn-secondary py-2 fw-bold text-white-50 disabled";
                btnBlockTicket.ToolTip = "Seat blocking is disabled within 14 days of departure per Rule 1";
                pnlBlockingRuleNotice.CssClass = "alert alert-warning p-2 small mb-3 text-start";
                litBlockingRuleNotice.Text = string.Format(
                    "<i class='fa-solid fa-triangle-exclamation text-warning me-1'></i> <strong>Rule 1 Applied (Departure &le; 14 days away):</strong> " +
                    "Flight departs in <strong>{0} day(s)</strong>. Seat blocking is <strong>disabled</strong> within 14 days of departure. Only direct <strong>[ Buy Ticket ]</strong> is permitted.",
                    daysUntilDeparture);
            }
        }

        if (ReturnFlightId > 0)
        {
            phReturnFlightCard.Visible = true;
            DataTable dtReturn = DbHelper.ExecuteQuery(query, new SqlParameter[] { new SqlParameter("@Id", ReturnFlightId) });
            if (dtReturn.Rows.Count > 0)
            {
                DataRow r = dtReturn.Rows[0];
                litReturnFlightNumber.Text = r["FlightNumber"].ToString();
                litReturnAirline.Text = r["AirlineName"].ToString();
                litReturnOrigin.Text = r["OriginCity"].ToString();
                litReturnDest.Text = r["DestinationCity"].ToString();

                DateTime dtDep = Convert.ToDateTime(r["DepartureTime"]);
                DateTime dtArr = Convert.ToDateTime(r["ArrivalTime"]);

                litReturnDepTime.Text = dtDep.ToString("hh:mm tt");
                litReturnDepDate.Text = dtDep.ToString("ddd, dd MMM yyyy");
                litReturnArrTime.Text = dtArr.ToString("hh:mm tt");
                litReturnArrDate.Text = dtArr.ToString("ddd, dd MMM yyyy");

                TimeSpan dur = dtArr - dtDep;
                litReturnDuration.Text = string.Format("{0}h{1}", (int)dur.TotalHours, dur.Minutes > 0 ? " " + dur.Minutes + "m" : "");
                litReturnSeats.Text = r["AvailableSeats"] + " Left";

                decimal returnBaseFare = TravelClass.StartsWith("Business") ? Convert.ToDecimal(r["BusinessPrice"]) : Convert.ToDecimal(r["EconomyPrice"]);
                ViewState["ReturnBasePrice"] = returnBaseFare;
            }
        }
        else
        {
            phReturnFlightCard.Visible = false;
            ViewState["ReturnBasePrice"] = 0m;
        }
    }

    private void CalculateAndDisplayPricing()
    {
        decimal onwardBase = ViewState["OnwardBasePrice"] != null ? Convert.ToDecimal(ViewState["OnwardBasePrice"]) : 15500m;
        decimal returnBase = ViewState["ReturnBasePrice"] != null ? Convert.ToDecimal(ViewState["ReturnBasePrice"]) : 0m;

        PriceBreakdown pb = ReservationHelper.CalculatePricing(onwardBase, returnBase, TravelClass, Adults, Children, Seniors);
        CalculatedGrandTotal = pb.GrandTotal;

        litTotalPassengerCount.Text = (Adults + Children + Seniors).ToString();
        litBaseFarePerAdult.Text = string.Format("{0:N0}", pb.CombinedBasePerAdult);
        litAdultLabel.Text = string.Format("Adult Passengers ({0}x):", Adults);
        litAdultSubtotal.Text = string.Format("{0:N0}", pb.AdultSubtotal);

        if (Children > 0)
        {
            phChildFare.Visible = true;
            litChildLabel.Text = string.Format("Children ({0}x with 25% discount):", Children);
            litChildSubtotal.Text = string.Format("{0:N0}", pb.ChildSubtotal);
        }
        else
        {
            phChildFare.Visible = false;
        }

        if (Seniors > 0)
        {
            phSeniorFare.Visible = true;
            litSeniorLabel.Text = string.Format("Senior Citizens ({0}x with 15% discount):", Seniors);
            litSeniorSubtotal.Text = string.Format("{0:N0}", pb.SeniorSubtotal);
        }
        else
        {
            phSeniorFare.Visible = false;
        }

        litTaxes.Text = string.Format("{0:N0}", pb.AirportTaxesAndFees);
        litGrandTotal.Text = string.Format("{0:N0}", pb.GrandTotal);
    }

    private void LoadCancellationPolicies()
    {
        DataTable dt = ReservationHelper.GetCancellationPolicies();
        rptCancellationPolicies.DataSource = dt;
        rptCancellationPolicies.DataBind();
    }

    public string GetRefundBadgeClass(object refundPctObj)
    {
        if (refundPctObj == null) return "bg-secondary";
        int pct = Convert.ToInt32(refundPctObj);
        if (pct >= 85) return "policy-badge-90";
        if (pct >= 65) return "policy-badge-70";
        if (pct >= 35) return "policy-badge-40";
        return "policy-badge-0";
    }

    protected void btnBuyTicket_Click(object sender, EventArgs e)
    {
        ExecuteReservation("Buy");
    }

    protected void btnBlockTicket_Click(object sender, EventArgs e)
    {
        bool canBlock = ViewState["CanBlock"] != null && (bool)ViewState["CanBlock"];
        if (!canBlock)
        {
            ShowError("Rule 1 Violation: Tickets cannot be blocked when departure is within 14 days. Only direct ticket purchase is permitted.");
            return;
        }
        ExecuteReservation("Block");
    }

    private void ExecuteReservation(string actionType)
    {
        if (!UserStateHelper.IsLoggedIn)
        {
            Response.Redirect("~/Public/Login.aspx?msg=auth_required");
            return;
        }

        string passengerName = txtPassengerName.Text.Trim();
        string cnic = txtCNIC.Text.Trim();

        if (string.IsNullOrEmpty(passengerName))
        {
            ShowError("Please enter the passenger's full name.");
            return;
        }

        int userId = UserStateHelper.CurrentUserId;
        string pnr;
        string err;

        bool success = ReservationHelper.CreateReservation(
            userId,
            OnwardFlightId,
            passengerName,
            TravelClass.Replace("_", " "),
            actionType,
            CalculatedGrandTotal,
            out pnr,
            out err);

        if (success)
        {
            pnlReservationForm.Visible = false;
            pnlBookingSuccess.Visible = true;

            litSuccessPassenger.Text = Server.HtmlEncode(passengerName);
            litSuccessFlight.Text = litOnwardFlightNumber.Text + " (" + litOnwardAirline.Text + ")";
            litSuccessRouteClass.Text = litOnwardOrigin.Text + " \u2192 " + litOnwardDest.Text + " (" + litTravelClass.Text + ")";
            litSuccessTotal.Text = litGrandTotal.Text;
            litSuccessPNR.Text = pnr;

            if (actionType.Equals("Buy", StringComparison.OrdinalIgnoreCase))
            {
                litSuccessHeading.Text = "Ticket Purchased & Confirmed!";
                litSuccessRefLabel.Text = "Confirmation Number (CNF):";
                litSuccessStatusBadge.Text = "<span class='badge bg-success fs-6'><i class='fa-solid fa-check-circle me-1'></i> Confirmed Ticket</span>";
                litWorkflowSteps.Text = "<span class='text-success fw-bold'><i class='fa-solid fa-credit-card me-1'></i> Payment Charged</span> &rarr; " +
                    "<span class='text-success fw-bold'><i class='fa-solid fa-chair me-1'></i> Seat Reserved</span> &rarr; " +
                    "<span class='text-primary fw-bold font-monospace me-1'><i class='fa-solid fa-barcode me-1'></i> " + pnr + "</span> &rarr; " +
                    "<span class='text-warning fw-bold'><i class='fa-solid fa-award me-1'></i> +350 SkyMiles Added</span>";
            }
            else
            {
                litSuccessHeading.Text = "Seat Blocked Successfully (48-Hour Hold)";
                litSuccessRefLabel.Text = "Blocking Number (BLK):";
                litSuccessStatusBadge.Text = "<span class='badge bg-warning text-dark fs-6'><i class='fa-solid fa-clock me-1'></i> Blocked (48-Hour Hold)</span>";
                litWorkflowSteps.Text = "<span class='text-warning fw-bold'><i class='fa-solid fa-chair me-1'></i> Seat Blocked in Flight</span> &rarr; " +
                    "<span class='text-success fw-bold'><i class='fa-solid fa-arrow-down me-1'></i> Seats Decremented</span> &rarr; " +
                    "<span class='text-primary fw-bold font-monospace me-1'><i class='fa-solid fa-barcode me-1'></i> " + pnr + "</span> &rarr; " +
                    "<span class='text-muted'><i class='fa-solid fa-hourglass-half me-1'></i> Valid for 48 Hours</span>";
            }
        }
        else
        {
            ShowError("Reservation failed: " + err);
        }
    }

    private void ShowError(string msg)
    {
        pnlAlert.Visible = true;
        litAlertMsg.Text = msg;
    }
}

