<%@ Page Title="Flight Search & Availability - Airline Reservation System" Language="C#" MasterPageFile="~/Shared/Site.Master" AutoEventWireup="true" CodeFile="SearchFlights.aspx.cs" Inherits="Public_SearchFlights" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .itinerary-step {
            position: relative;
            padding-left: 24px;
        }
        .itinerary-step::before {
            content: '';
            position: absolute;
            left: 6px;
            top: 10px;
            bottom: -10px;
            width: 2px;
            background: #cbd5e1;
        }
        .itinerary-step:last-child::before {
            display: none;
        }
        .itinerary-dot {
            position: absolute;
            left: 0;
            top: 6px;
            width: 14px;
            height: 14px;
            border-radius: 50%;
            background: #0077b6;
            border: 2px solid #fff;
            box-shadow: 0 0 0 2px #0077b6;
        }
        .layover-pill {
            background-color: #fef3c7;
            color: #92400e;
            border: 1px dashed #f59e0b;
            border-radius: 20px;
            padding: 4px 12px;
            font-size: 0.8rem;
            font-weight: 600;
            display: inline-block;
            margin: 6px 0 6px 24px;
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container py-4">
        <!-- Breadcrumb -->
        <nav aria-label="breadcrumb" class="mb-3">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="<%= ResolveUrl("~/Public/Home.aspx") %>">Home</a></li>
                <li class="breadcrumb-item active" aria-current="page">Flight Search &amp; Availability</li>
            </ol>
        </nav>

        <!-- Main Search Card -->
        <div class="ars-card mb-4">
            <div class="card-header-custom d-flex justify-content-between align-items-center">
                <div>
                    <h4 class="fw-bold mb-0"><i class="fa-solid fa-plane-departure me-2"></i>Flight Search &amp; Availability Check</h4>
                    <p class="small mb-0 text-white-50">Section 3.3 â€” Origin/Destination Verification, Ambiguity Resolution &amp; Route Selection</p>
                </div>
                <% if (AirlineReservationSystem.UserStateHelper.IsLoggedIn) { %>
                    <span class="badge bg-success"><i class="fa-solid fa-user-check me-1"></i> Registered User Mode</span>
                <% } else { %>
                    <span class="badge bg-warning text-dark"><i class="fa-solid fa-user-clock me-1"></i> Guest Availability Mode</span>
                <% } %>
            </div>

            <div class="p-4 p-md-5">
                <!-- Validation & System Error Alerts -->
                <asp:Panel ID="pnlAlert" runat="server" Visible="false" CssClass="alert alert-danger mb-4">
                    <i class="fa-solid fa-circle-exclamation me-2"></i>
                    <asp:Literal ID="litAlertMsg" runat="server"></asp:Literal>
                </asp:Panel>

                <!-- City Ambiguity Resolution Panel (Section 3.3.1) -->
                <asp:Panel ID="pnlAmbiguity" runat="server" Visible="false" CssClass="alert alert-warning mb-4 border-warning shadow-sm">
                    <div class="d-flex align-items-start">
                        <i class="fa-solid fa-triangle-exclamation fa-2x text-warning me-3 mt-1"></i>
                        <div class="flex-grow-1">
                            <h5 class="fw-bold text-dark mb-1">Ambiguity Detected: Same-Name Cities Found</h5>
                            <p class="mb-2 text-dark">
                                More than one city matches the name entered (<asp:Literal ID="litAmbiguousCityName" runat="server"></asp:Literal>). 
                                Per Section 3.3.1 of the project specification, please select your specific intended location:
                            </p>
                            <div class="d-flex gap-2 flex-wrap mt-2">
                                <asp:Repeater ID="rptAmbiguousCandidates" runat="server" OnItemCommand="rptAmbiguousCandidates_ItemCommand">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="btnSelectCandidate" runat="server" 
                                            CommandName="SelectCity" 
                                            CommandArgument='<%# Eval("CityName") + "|" + Eval("QualifiedName") + "|" + Eval("AirportCode") %>'
                                            CssClass="btn btn-outline-dark btn-sm bg-white">
                                            <i class="fa-solid fa-location-dot text-danger me-1"></i>
                                            <strong><%# Eval("QualifiedName") %></strong>
                                        </asp:LinkButton>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </div>
                        </div>
                    </div>
                </asp:Panel>

                <!-- Nearest Serviced City Suggestion Panel (Section 3.3.1) -->
                <asp:Panel ID="pnlNearestService" runat="server" Visible="false" CssClass="alert alert-info mb-4 border-info shadow-sm">
                    <div class="d-flex align-items-start">
                        <i class="fa-solid fa-circle-info fa-2x text-info me-3 mt-1"></i>
                        <div class="flex-grow-1">
                            <h5 class="fw-bold text-dark mb-1">AeroFly Route &amp; Service Notice</h5>
                            <p class="mb-2 text-dark">
                                <asp:Literal ID="litNearestNotice" runat="server"></asp:Literal>
                            </p>
                            <asp:Button ID="btnApplyNearestCity" runat="server" Text="Use Nearest Serviced Airport" 
                                CssClass="btn btn-primary btn-sm" OnClick="btnApplyNearestCity_Click" />
                        </div>
                    </div>
                </asp:Panel>

                <!-- Search Form Controls -->
                <div class="row g-3">
                    <!-- Origin City Input with Autocomplete Datalist -->
                    <div class="col-md-6 col-lg-3">
                        <label class="form-label fw-semibold">
                            <i class="fa-solid fa-plane-departure text-primary me-1"></i> Origin City <span class="text-danger">*</span>
                        </label>
                        <asp:TextBox ID="txtOrigin" runat="server" CssClass="form-control form-control-lg" placeholder="e.g. Karachi or KHI" list="dlOriginCities" />
                        <datalist id="dlOriginCities">
                            <option value="Karachi">Karachi (KHI) - Primary Hub</option>
                            <option value="Islamabad">Islamabad (ISB) - Capital Hub</option>
                            <option value="Lahore">Lahore (LHE) - Major Hub</option>
                            <option value="Dubai">Dubai (DXB) - International Hub</option>
                            <option value="London">London (LHR) - European Gateway</option>
                            <option value="Istanbul">Istanbul (IST) - Transit Hub</option>
                            <option value="New York">New York (JFK) - North America</option>
                            <option value="Hyderabad">Hyderabad (Ambiguity Test Case)</option>
                            <option value="Rawalpindi">Rawalpindi (Nearest City Test Case)</option>
                            <option value="Faisalabad">Faisalabad (Nearest City Test Case)</option>
                        </datalist>
                        <small class="text-muted">Type city name or airport code.</small>
                    </div>

                    <!-- Destination City Input with Autocomplete Datalist -->
                    <div class="col-md-6 col-lg-3">
                        <label class="form-label fw-semibold">
                            <i class="fa-solid fa-plane-arrival text-danger me-1"></i> Destination City <span class="text-danger">*</span>
                        </label>
                        <asp:TextBox ID="txtDestination" runat="server" CssClass="form-control form-control-lg" placeholder="e.g. London or LHR" list="dlDestCities" />
                        <datalist id="dlDestCities">
                            <option value="London">London (LHR) - Direct from ISB / via DXB, IST</option>
                            <option value="Dubai">Dubai (DXB) - Direct from KHI</option>
                            <option value="Islamabad">Islamabad (ISB) - Direct from KHI</option>
                            <option value="Lahore">Lahore (LHE) - Direct from KHI</option>
                            <option value="New York">New York (JFK) - via Dubai Hub</option>
                            <option value="Istanbul">Istanbul (IST) - Direct from KHI</option>
                            <option value="Hyderabad">Hyderabad (Ambiguity Test Case)</option>
                            <option value="Abbottabad">Abbottabad (Nearest City Test Case)</option>
                            <option value="Cambridge">Cambridge (Nearest City Test Case)</option>
                        </datalist>
                        <small class="text-muted">Connecting routes suggested automatically.</small>
                    </div>

                    <!-- Trip Type Selection -->
                    <div class="col-md-6 col-lg-3">
                        <label class="form-label fw-semibold">
                            <i class="fa-solid fa-arrows-split-up-and-left text-secondary me-1"></i> Trip Type
                        </label>
                        <asp:DropDownList ID="ddlTripType" runat="server" CssClass="form-select form-select-lg" AutoPostBack="true" OnSelectedIndexChanged="ddlTripType_SelectedIndexChanged">
                            <asp:ListItem Value="OneWay" Text="One-Way Journey" Selected="True" />
                            <asp:ListItem Value="RoundTrip" Text="Round-Trip Journey" />
                        </asp:DropDownList>
                        <small class="text-muted">Select single or return flight.</small>
                    </div>

                    <!-- Travel Class Combinations Dropdown (Section 3.3.4) -->
                    <div class="col-md-6 col-lg-3">
                        <label class="form-label fw-semibold">
                            <i class="fa-solid fa-couch text-warning me-1"></i> Class Combinations
                        </label>
                        <asp:DropDownList ID="ddlTravelClass" runat="server" CssClass="form-select form-select-lg">
                            <asp:ListItem Value="Economy_NonSmoking" Text="Economy Class (Non-Smoking)" Selected="True" />
                            <asp:ListItem Value="Economy_Smoking" Text="Economy Class (Smoking)" />
                            <asp:ListItem Value="Business_NonSmoking" Text="Business Class (Non-Smoking)" />
                            <asp:ListItem Value="Business_Smoking" Text="Business Class (Smoking)" />
                            <asp:ListItem Value="First_NonSmoking" Text="First Class (Non-Smoking)" />
                            <asp:ListItem Value="First_Smoking" Text="First Class (Smoking)" />
                            <asp:ListItem Value="Club_NonSmoking" Text="Club Class (Non-Smoking)" />
                        </asp:DropDownList>
                        <small class="text-muted">Combinations per Section 3.3.4.</small>
                    </div>

                    <!-- Departure Date -->
                    <div class="col-md-6 col-lg-3">
                        <label class="form-label fw-semibold">
                            <i class="fa-solid fa-calendar-day text-primary me-1"></i> Departure Date <span class="text-danger">*</span>
                        </label>
                        <asp:TextBox ID="txtDepartureDate" runat="server" CssClass="form-control" TextMode="Date" />
                        <small class="text-muted">Cannot select past dates.</small>
                    </div>

                    <!-- Return Date (Active when Round-Trip selected) -->
                    <div class="col-md-6 col-lg-3">
                        <label class="form-label fw-semibold">
                            <i class="fa-solid fa-calendar-week text-danger me-1"></i> Return Date
                        </label>
                        <asp:TextBox ID="txtReturnDate" runat="server" CssClass="form-control" TextMode="Date" />
                        <small class="text-muted">Required if Round-Trip is selected.</small>
                    </div>

                    <!-- Passenger Counts -->
                    <div class="col-md-6 col-lg-4">
                        <label class="form-label fw-semibold">
                            <i class="fa-solid fa-users text-dark me-1"></i> Passenger Breakdown
                        </label>
                        <div class="input-group">
                            <span class="input-group-text small bg-light" title="Adults (12+ yrs)">Adults</span>
                            <asp:TextBox ID="txtAdults" runat="server" CssClass="form-control text-center" TextMode="Number" Text="1" min="1" max="9" />
                            <span class="input-group-text small bg-light" title="Children (2-11 yrs)">Children</span>
                            <asp:TextBox ID="txtChildren" runat="server" CssClass="form-control text-center" TextMode="Number" Text="0" min="0" max="9" />
                            <span class="input-group-text small bg-light" title="Seniors (60+ yrs)">Seniors</span>
                            <asp:TextBox ID="txtSeniors" runat="server" CssClass="form-control text-center" TextMode="Number" Text="0" min="0" max="9" />
                        </div>
                        <small class="text-muted">Minimum 1 adult required.</small>
                    </div>

                    <!-- Submit Button -->
                    <div class="col-md-6 col-lg-2 d-flex align-items-end">
                        <asp:Button ID="btnSearchFlights" runat="server" Text="Search Flights" 
                            CssClass="btn btn-primary-custom w-100 py-2 fs-5" OnClick="btnSearchFlights_Click" />
                    </div>
                </div>
            </div>
        </div>

        <!-- Direct Flights Results Section -->
        <asp:Panel ID="pnlDirectResults" runat="server" Visible="false" CssClass="mb-5">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h4 class="fw-bold text-dark mb-0">
                    <i class="fa-solid fa-plane text-success me-2"></i>Direct Operational Flights
                </h4>
                <span class="badge bg-success fs-6"><asp:Literal ID="litDirectCount" runat="server">0</asp:Literal> Direct Option(s)</span>
            </div>

            <asp:Repeater ID="rptDirectFlights" runat="server">
                <ItemTemplate>
                    <div class="ars-card mb-3 p-4">
                        <div class="row align-items-center gy-3">
                            <div class="col-md-3">
                                <span class="badge bg-primary-subtle text-primary fw-bold px-2 py-1 mb-1">
                                    <i class="fa-solid fa-ticket me-1"></i><%# Eval("FlightNumber") %>
                                </span>
                                <h5 class="fw-bold mb-0 text-dark"><%# Eval("AirlineName") %></h5>
                                <small class="text-success fw-semibold"><i class="fa-solid fa-check-circle me-1"></i>Direct Non-Stop</small>
                            </div>

                            <div class="col-md-4">
                                <div class="d-flex align-items-center justify-content-between">
                                    <div>
                                        <div class="fs-4 fw-bold mb-0"><%# Convert.ToDateTime(Eval("DepartureTime")).ToString("hh:mm tt") %></div>
                                        <div class="small fw-semibold text-primary"><%# Eval("OriginCity") %></div>
                                        <div class="small text-muted"><%# Convert.ToDateTime(Eval("DepartureTime")).ToString("dd MMM yyyy") %></div>
                                    </div>
                                    <div class="text-center px-3">
                                        <small class="text-muted d-block">
                                            <%# Math.Round((Convert.ToDateTime(Eval("ArrivalTime")) - Convert.ToDateTime(Eval("DepartureTime"))).TotalHours, 1) %> hrs
                                        </small>
                                        <i class="fa-solid fa-arrow-right-long text-primary fa-lg"></i>
                                    </div>
                                    <div class="text-end">
                                        <div class="fs-4 fw-bold mb-0"><%# Convert.ToDateTime(Eval("ArrivalTime")).ToString("hh:mm tt") %></div>
                                        <div class="small fw-semibold text-danger"><%# Eval("DestinationCity") %></div>
                                        <div class="small text-muted"><%# Convert.ToDateTime(Eval("ArrivalTime")).ToString("dd MMM yyyy") %></div>
                                    </div>
                                </div>
                            </div>

                            <div class="col-md-2 text-center text-md-start">
                                <span class="badge bg-info-subtle text-info-emphasis border mb-1">
                                    <i class="fa-solid fa-chair me-1"></i><%# Eval("AvailableSeats") %> Seats Left
                                </span>
                                <div class="small text-muted">Status: <strong class="text-success"><%# Eval("Status") %></strong></div>
                            </div>

                            <div class="col-md-3 text-md-end">
                                <div class="small text-muted">Fares starting from:</div>
                                <div class="fs-4 fw-bold text-success mb-2">
                                    PKR <%# string.Format("{0:N0}", Eval("EconomyPrice")) %>
                                </div>

                                <% if (AirlineReservationSystem.UserStateHelper.IsLoggedIn) { %>
                                    <div class="btn-group w-100">
                                        <a href='Dashboard.aspx' class="btn btn-success btn-sm">
                                            <i class="fa-solid fa-ticket me-1"></i> Book Ticket
                                        </a>
                                        <a href='Dashboard.aspx' class="btn btn-outline-warning text-dark btn-sm fw-semibold" title="Hold/Block seat per Section 1.1">
                                            <i class="fa-solid fa-clock-rotate-left me-1"></i> Block Seat
                                        </a>
                                    </div>
                                <% } else { %>
                                    <a href="Login.aspx?action=book" class="btn btn-outline-primary btn-sm w-100" title="Guest view only. Please login to reserve.">
                                        <i class="fa-solid fa-lock me-1"></i> Login to Book / Block
                                    </a>
                                    <small class="text-muted d-block mt-1">Guests can check availability only</small>
                                <% } %>
                            </div>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </asp:Panel>

        <!-- Connecting Flights / Multi-Segment Routes Section (Section 3.3.1 Route Selection) -->
        <asp:Panel ID="pnlConnectingResults" runat="server" Visible="false" CssClass="mb-5">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <div>
                    <h4 class="fw-bold text-dark mb-0">
                        <i class="fa-solid fa-route text-primary me-2"></i>Connecting Flights &amp; Transfer Points (Route Selection Algorithm)
                    </h4>
                    <p class="text-muted small mb-0">Multi-leg itineraries with intermediate stopover points per Section 3.3.1</p>
                </div>
                <span class="badge bg-primary fs-6"><asp:Literal ID="litConnectingCount" runat="server">0</asp:Literal> Route(s) Found</span>
            </div>

            <asp:Repeater ID="rptConnectingRoutes" runat="server">
                <ItemTemplate>
                    <div class="ars-card mb-4 p-4 border-start border-primary border-4">
                        <div class="row align-items-center gy-3">
                            <div class="col-lg-8">
                                <div class="d-flex align-items-center gap-2 mb-3">
                                    <span class="badge bg-secondary">1 Stopover</span>
                                    <span class="fw-bold text-dark">
                                        <%# ((System.Data.DataRow)Eval("Leg1"))["OriginCity"] %> 
                                        &rarr; <span class="text-primary"><%# Eval("TransferCity") %> (Transfer Hub)</span> 
                                        &rarr; <%# ((System.Data.DataRow)Eval("Leg2"))["DestinationCity"] %>
                                    </span>
                                </div>

                                <!-- Itinerary Timeline Steps -->
                                <div class="ps-2">
                                    <!-- Leg 1 -->
                                    <div class="itinerary-step pb-2">
                                        <span class="itinerary-dot"></span>
                                        <div class="d-flex justify-content-between">
                                            <div>
                                                <strong>Flight 1: <%# ((System.Data.DataRow)Eval("Leg1"))["FlightNumber"] %></strong> (<%# ((System.Data.DataRow)Eval("Leg1"))["AirlineName"] %>)
                                                <div class="small text-muted">
                                                    Departs: <%# ((System.Data.DataRow)Eval("Leg1"))["OriginCity"] %> at <%# Convert.ToDateTime(((System.Data.DataRow)Eval("Leg1"))["DepartureTime"]).ToString("dd MMM, hh:mm tt") %>
                                                </div>
                                                <div class="small text-muted">
                                                    Arrives: <%# ((System.Data.DataRow)Eval("Leg1"))["DestinationCity"] %> at <%# Convert.ToDateTime(((System.Data.DataRow)Eval("Leg1"))["ArrivalTime"]).ToString("dd MMM, hh:mm tt") %>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Layover / Stopover Pill -->
                                    <div class="layover-pill">
                                        <i class="fa-solid fa-clock me-1"></i> Layover / Transfer in <%# Eval("TransferCity") %>: 
                                        <strong><%# ((TimeSpan)Eval("LayoverDuration")).Hours %> hrs <%# ((TimeSpan)Eval("LayoverDuration")).Minutes %> mins</strong>
                                    </div>

                                    <!-- Leg 2 -->
                                    <div class="itinerary-step pt-2">
                                        <span class="itinerary-dot bg-success"></span>
                                        <div>
                                            <strong>Flight 2: <%# ((System.Data.DataRow)Eval("Leg2"))["FlightNumber"] %></strong> (<%# ((System.Data.DataRow)Eval("Leg2"))["AirlineName"] %>)
                                            <div class="small text-muted">
                                                Departs: <%# ((System.Data.DataRow)Eval("Leg2"))["OriginCity"] %> at <%# Convert.ToDateTime(((System.Data.DataRow)Eval("Leg2"))["DepartureTime"]).ToString("dd MMM, hh:mm tt") %>
                                            </div>
                                            <div class="small text-muted">
                                                Final Arrival: <%# ((System.Data.DataRow)Eval("Leg2"))["DestinationCity"] %> at <%# Convert.ToDateTime(((System.Data.DataRow)Eval("Leg2"))["ArrivalTime"]).ToString("dd MMM, hh:mm tt") %>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Pricing & Action -->
                            <div class="col-lg-4 text-lg-end border-start-lg ps-lg-4">
                                <div class="badge bg-info-subtle text-info-emphasis border mb-1">
                                    <i class="fa-solid fa-chair me-1"></i> <%# Eval("MinAvailableSeats") %> Seats Available
                                </div>
                                <div class="small text-muted">Total Combined Economy Fare:</div>
                                <div class="fs-3 fw-bold text-success mb-2">
                                    PKR <%# string.Format("{0:N0}", Eval("TotalEconomyPrice")) %>
                                </div>
                                <div class="small text-muted mb-3">
                                    Business Class: PKR <%# string.Format("{0:N0}", Eval("TotalBusinessPrice")) %>
                                </div>

                                <% if (AirlineReservationSystem.UserStateHelper.IsLoggedIn) { %>
                                    <div class="btn-group w-100">
                                        <a href='Dashboard.aspx' class="btn btn-success">
                                            <i class="fa-solid fa-ticket me-1"></i> Book Connecting Route
                                        </a>
                                        <a href='Dashboard.aspx' class="btn btn-outline-warning text-dark fw-semibold" title="Hold/Block seat">
                                            <i class="fa-solid fa-clock-rotate-left me-1"></i> Block
                                        </a>
                                    </div>
                                <% } else { %>
                                    <a href="Login.aspx?action=book" class="btn btn-outline-primary w-100">
                                        <i class="fa-solid fa-lock me-1"></i> Login to Book Route
                                    </a>
                                <% } %>
                            </div>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </asp:Panel>

        <!-- No Flights Fallback Panel -->
        <asp:Panel ID="pnlNoFlightsFound" runat="server" Visible="false" CssClass="ars-card p-5 text-center my-4">
            <i class="fa-solid fa-plane-slash fa-3x text-muted mb-3"></i>
            <h4 class="fw-bold text-dark">No Scheduled Flights Available</h4>
            <p class="text-muted mx-auto" style="max-width: 600px;">
                No direct or connecting flight routes were found matching your exact origin, destination, and departure date.
                Try adjusting your travel dates or searching between our primary hubs (Karachi, Islamabad, Lahore, Dubai, London).
            </p>
        </asp:Panel>
    </div>
</asp:Content>


