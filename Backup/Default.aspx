<%@ Page Title="Home - Airline Reservation System" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeFile="Default.aspx.cs" Inherits="Default" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Hero Banner with 3D Depth -->
    <section class="hero-banner text-center text-white">
        <div class="container position-relative" style="z-index: 2;">
            <div class="mb-3">
                <i class="fa-solid fa-plane-up fa-3x text-warning plane-float" style="filter: drop-shadow(0 10px 15px rgba(0,0,0,0.5));"></i>
            </div>
            <span class="badge bg-warning text-dark px-3 py-2 rounded-pill fw-bold text-uppercase mb-3">
                <i class="fa-solid fa-earth-americas me-1"></i> Premium Global Flight Network
            </span>
            <h1 class="display-4 fw-bold mb-3">Welcome to AeroFly Airline Reservation System</h1>
            <p class="lead mb-4 mx-auto" style="max-width: 750px;">
                Experience fast, intuitive, and modern flight scheduling and seat reservations.
                Check live flight availability, seat maps, and book your journey seamlessly.
            </p>

            <!-- Quick Action Buttons -->
            <div class="d-flex justify-content-center gap-3 flex-wrap">
                <% if (!AirlineReservationSystem.UserStateHelper.IsLoggedIn) { %>
                    <a href="Guest.aspx" class="btn btn-outline-light btn-lg px-4">
                        <i class="fa-solid fa-user-secret me-2"></i>Continue as Guest
                    </a>
                    <a href="Login.aspx" class="btn btn-warning btn-lg px-4 text-dark fw-bold">
                        <i class="fa-solid fa-right-to-bracket me-2"></i>Registered User Login
                    </a>
                <% } else { %>
                    <a href="Dashboard.aspx" class="btn btn-success btn-lg px-4">
                        <i class="fa-solid fa-gauge-high me-2"></i>Go to User Dashboard
                    </a>
                <% } %>
            </div>
        </div>
    </section>

    <div class="container">
        <!-- Guest vs Registered User System State Card -->
        <div class="row g-4 mb-5">
            <div class="col-md-6">
                <div class="ars-card h-100 p-4 border-start border-warning border-5">
                    <div class="d-flex align-items-center mb-3">
                        <div class="bg-warning-subtle text-warning p-3 rounded-circle me-3">
                            <i class="fa-solid fa-user-clock fa-2x"></i>
                        </div>
                        <div>
                            <h4 class="mb-0 fw-bold">Guest User Access</h4>
                            <span class="badge bg-secondary">Read-Only Availability</span>
                        </div>
                    </div>
                    <p class="text-muted">A guest passenger can explore flight timings, pricing, and availability without creating an account:</p>
                    <ul class="list-unstyled mb-4">
                        <li class="mb-2 text-success"><i class="fa-solid fa-circle-check me-2"></i> Check live flight schedules for given dates</li>
                        <li class="mb-2 text-success"><i class="fa-solid fa-circle-check me-2"></i> View seat availability and ticket pricing</li>
                        <li class="mb-2 text-success"><i class="fa-solid fa-circle-check me-2"></i> Browse ongoing discount offers &amp; promotions</li>
                        <li class="mb-2 text-danger"><i class="fa-solid fa-circle-xmark me-2"></i> <strong>Cannot</strong> block seats or buy tickets</li>
                        <li class="mb-2 text-danger"><i class="fa-solid fa-circle-xmark me-2"></i> <strong>Cannot</strong> earn SkyMiles or view user dashboard</li>
                    </ul>
                    <% if (!AirlineReservationSystem.UserStateHelper.IsLoggedIn) { %>
                        <a href="Guest.aspx" class="btn btn-outline-warning w-100 fw-bold">
                            <i class="fa-solid fa-compass me-1"></i> Browse Availability as Guest
                        </a>
                    <% } %>
                </div>
            </div>

            <div class="col-md-6">
                <div class="ars-card h-100 p-4 border-start border-success border-5">
                    <div class="d-flex align-items-center mb-3">
                        <div class="bg-success-subtle text-success p-3 rounded-circle me-3">
                            <i class="fa-solid fa-id-badge fa-2x"></i>
                        </div>
                        <div>
                            <h4 class="mb-0 fw-bold">Registered User Access</h4>
                            <span class="badge bg-success">Full Transaction Privileges</span>
                        </div>
                    </div>
                    <p class="text-muted">Registered members with an active AeroFly account enjoy complete airline reservation powers:</p>
                    <ul class="list-unstyled mb-4">
                        <li class="mb-2 text-success"><i class="fa-solid fa-circle-check me-2"></i> Search flights &amp; check live seat inventory</li>
                        <li class="mb-2 text-success"><i class="fa-solid fa-circle-check me-2"></i> <strong>Block tickets</strong> prior to final confirmation</li>
                        <li class="mb-2 text-success"><i class="fa-solid fa-circle-check me-2"></i> <strong>Purchase / Reserve tickets</strong> with quick checkout</li>
                        <li class="mb-2 text-success"><i class="fa-solid fa-circle-check me-2"></i> Reschedule or cancel existing reservations</li>
                        <li class="mb-2 text-success"><i class="fa-solid fa-circle-check me-2"></i> Earn &amp; redeem <strong>SkyMiles</strong> on every booking</li>
                    </ul>
                    <% if (!AirlineReservationSystem.UserStateHelper.IsLoggedIn) { %>
                        <div class="d-flex gap-2">
                            <a href="Login.aspx" class="btn btn-primary-custom flex-grow-1">
                                <i class="fa-solid fa-right-to-bracket me-1"></i> Login
                            </a>
                            <a href="Register.aspx" class="btn btn-outline-primary flex-grow-1">
                                <i class="fa-solid fa-user-plus me-1"></i> Create Account
                            </a>
                        </div>
                    <% } else { %>
                        <a href="Dashboard.aspx" class="btn btn-success w-100 fw-bold">
                            <i class="fa-solid fa-gauge-high me-1"></i> Open My User Dashboard
                        </a>
                    <% } %>
                </div>
            </div>
        </div>

        <!-- Flight Availability Search Box -->
        <div id="search-flights" class="ars-card mb-5">
            <div class="card-header-custom d-flex justify-content-between align-items-center flex-wrap gap-2">
                <span class="fs-5"><i class="fa-solid fa-magnifying-glass me-2"></i> Live Flight Schedules &amp; Availability</span>
                <div class="d-flex gap-2 flex-wrap">
                    <a href="FlightStatus.aspx" class="btn btn-outline-light btn-sm fw-bold">
                        <i class="fa-solid fa-clock me-1"></i> Public Flight Status &rarr;
                    </a>
                    <a href="SearchFlights.aspx" class="btn btn-warning btn-sm text-dark fw-bold">
                        <i class="fa-solid fa-route me-1"></i> Advanced Flight Search &rarr;
                    </a>
                </div>
            </div>
            <div class="p-4">
                <asp:Panel ID="pnlSearchAlert" runat="server" Visible="false" CssClass="alert alert-info">
                    <asp:Literal ID="litSearchAlert" runat="server"></asp:Literal>
                </asp:Panel>

                <div class="row g-3">
                    <div class="col-md-3">
                        <label class="form-label fw-semibold"><i class="fa-solid fa-plane-departure text-primary me-1"></i> Origin City</label>
                        <asp:DropDownList ID="ddlOrigin" runat="server" CssClass="form-select">
                            <asp:ListItem Value="" Text="-- Select Origin City --" />
                            <asp:ListItem Value="Karachi" Text="Karachi (KHI)" />
                            <asp:ListItem Value="Islamabad" Text="Islamabad (ISB)" />
                            <asp:ListItem Value="Lahore" Text="Lahore (LHE)" />
                            <asp:ListItem Value="Dubai" Text="Dubai (DXB)" />
                            <asp:ListItem Value="London" Text="London (LHR)" />
                        </asp:DropDownList>
                    </div>

                    <div class="col-md-3">
                        <label class="form-label fw-semibold"><i class="fa-solid fa-plane-arrival text-danger me-1"></i> Destination City</label>
                        <asp:DropDownList ID="ddlDestination" runat="server" CssClass="form-select">
                            <asp:ListItem Value="" Text="-- Select Destination City --" />
                            <asp:ListItem Value="Islamabad" Text="Islamabad (ISB)" />
                            <asp:ListItem Value="Lahore" Text="Lahore (LHE)" />
                            <asp:ListItem Value="Karachi" Text="Karachi (KHI)" />
                            <asp:ListItem Value="Dubai" Text="Dubai (DXB)" />
                            <asp:ListItem Value="London" Text="London (LHR)" />
                        </asp:DropDownList>
                    </div>

                    <div class="col-md-2">
                        <label class="form-label fw-semibold"><i class="fa-solid fa-chair text-muted me-1"></i> Travel Class</label>
                        <asp:DropDownList ID="ddlClass" runat="server" CssClass="form-select">
                            <asp:ListItem Value="Economy" Text="Economy Class" />
                            <asp:ListItem Value="Business" Text="Business Class" />
                            <asp:ListItem Value="First" Text="First Class" />
                        </asp:DropDownList>
                    </div>

                    <div class="col-md-2">
                        <label class="form-label fw-semibold"><i class="fa-solid fa-arrows-split-up-and-left text-muted me-1"></i> Trip Type</label>
                        <asp:DropDownList ID="ddlTripType" runat="server" CssClass="form-select">
                            <asp:ListItem Value="OneWay" Text="One-Way" />
                            <asp:ListItem Value="RoundTrip" Text="Round-Trip" />
                        </asp:DropDownList>
                    </div>

                    <div class="col-md-2 d-flex align-items-end">
                        <asp:Button ID="btnSearch" runat="server" Text="Search Flights" CssClass="btn btn-primary-custom w-100" OnClick="btnSearch_Click" />
                    </div>
                </div>

                <!-- Flight Search Results Repeater -->
                <div class="mt-4">
                    <asp:Panel ID="pnlResults" runat="server" Visible="false">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h5 class="fw-bold mb-0"><i class="fa-solid fa-list-check me-2"></i> Available Flights Found</h5>
                            <% if (AirlineReservationSystem.UserStateHelper.IsLoggedIn) { %>
                                <span class="badge bg-success"><i class="fa-solid fa-shield-halved me-1"></i> Reservation Authorized</span>
                            <% } else { %>
                                <span class="badge bg-warning text-dark"><i class="fa-solid fa-lock me-1"></i> Guest View Only (Login required to book)</span>
                            <% } %>
                        </div>

                        <asp:Repeater ID="rptFlights" runat="server">
                            <HeaderTemplate>
                                <div class="table-responsive">
                                    <table class="table table-hover align-middle border">
                                        <thead class="table-light">
                                            <tr>
                                                <th>Flight #</th>
                                                <th>Airline</th>
                                                <th>Route</th>
                                                <th>Departure &bull; Arrival</th>
                                                <th>Available Seats</th>
                                                <th>Economy Price</th>
                                                <th>Business Price</th>
                                                <th class="text-center">Action</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                            </HeaderTemplate>
                            <ItemTemplate>
                                <tr>
                                    <td class="fw-bold text-primary"><%# Eval("FlightNumber") %></td>
                                    <td><%# Eval("AirlineName") %></td>
                                    <td>
                                        <span class="badge bg-primary-subtle text-primary"><%# Eval("OriginCity") %></span>
                                        <i class="fa-solid fa-arrow-right mx-1 text-muted"></i>
                                        <span class="badge bg-danger-subtle text-danger"><%# Eval("DestinationCity") %></span>
                                    </td>
                                    <td>
                                        <div class="small fw-semibold"><%# Convert.ToDateTime(Eval("DepartureTime")).ToString("dd MMM yyyy, hh:mm tt") %></div>
                                        <div class="small text-muted"><%# Convert.ToDateTime(Eval("ArrivalTime")).ToString("dd MMM yyyy, hh:mm tt") %></div>
                                    </td>
                                    <td>
                                        <span class="badge bg-info text-dark"><%# Eval("AvailableSeats") %> seats left</span>
                                    </td>
                                    <td class="fw-bold text-success">PKR <%# string.Format("{0:N0}", Eval("EconomyPrice")) %></td>
                                    <td class="fw-bold text-purple">PKR <%# string.Format("{0:N0}", Eval("BusinessPrice")) %></td>
                                    <td class="text-center">
                                        <% if (AirlineReservationSystem.UserStateHelper.IsLoggedIn) { %>
                                            <a href='Dashboard.aspx' class="btn btn-sm btn-success">
                                                <i class="fa-solid fa-ticket me-1"></i> Book / Block
                                            </a>
                                        <% } else { %>
                                            <a href="Login.aspx?action=book" class="btn btn-sm btn-outline-primary" title="Login required to book or block seats">
                                                <i class="fa-solid fa-lock me-1"></i> Login to Book
                                            </a>
                                        <% } %>
                                    </td>
                                </tr>
                            </ItemTemplate>
                            <FooterTemplate>
                                        </tbody>
                                    </table>
                                </div>
                            </FooterTemplate>
                        </asp:Repeater>
                    </asp:Panel>
                </div>
            </div>
        </div>

        <!-- Feature Cards (AeroFly Highlights) with 3D Depth -->
        <div class="row g-4 mb-5">
            <div class="col-md-3">
                <div class="ars-card p-4 text-center h-100">
                    <div class="icon-box-3d mx-auto">
                        <i class="fa-solid fa-tag"></i>
                    </div>
                    <h5 class="fw-bold mb-2">Best Price Guarantee</h5>
                    <p class="text-muted small mb-0">Competitive fares with transparent fee structures and exclusive seasonal discounts.</p>
                </div>
            </div>
            <div class="col-md-3">
                <div class="ars-card p-4 text-center h-100">
                    <div class="icon-box-3d mx-auto text-success">
                        <i class="fa-solid fa-plane-circle-check"></i>
                    </div>
                    <h5 class="fw-bold mb-2">Easy Booking</h5>
                    <p class="text-muted small mb-0">Reserve in 4 simple steps or block seats up to 2 weeks before departure.</p>
                </div>
            </div>
            <div class="col-md-3">
                <div class="ars-card p-4 text-center h-100">
                    <div class="icon-box-3d mx-auto text-warning">
                        <i class="fa-solid fa-headset"></i>
                    </div>
                    <h5 class="fw-bold mb-2">24/7 Support</h5>
                    <p class="text-muted small mb-0">Dedicated round-the-clock customer assistance for ticketing and flight inquiries.</p>
                </div>
            </div>
            <div class="col-md-3">
                <div class="ars-card p-4 text-center h-100">
                    <div class="icon-box-3d mx-auto text-info">
                        <i class="fa-solid fa-shield-halved"></i>
                    </div>
                    <h5 class="fw-bold mb-2">Secure Payments</h5>
                    <p class="text-muted small mb-0">Bank-grade encryption for all preferred credit card transactions and refund credits.</p>
                </div>
            </div>
        </div>

        <!-- Key System Highlights -->
        <div class="row g-4 mb-4">
            <div class="col-md-4">
                <div class="stat-box">
                    <div class="number"><i class="fa-solid fa-users text-primary me-1"></i> 2 States</div>
                    <div class="label">Guest User &bull; Registered User</div>
                    <p class="small text-muted mt-2 mb-0">Distinct access control for guest passengers and registered travelers.</p>
                </div>
            </div>
            <div class="col-md-4">
                <div class="stat-box">
                    <div class="number"><i class="fa-solid fa-award text-warning me-1"></i> SkyMiles</div>
                    <div class="label">Frequent Flyer Program</div>
                    <p class="small text-muted mt-2 mb-0">Automatic profile creation with sky miles initialized to zero.</p>
                </div>
            </div>
            <div class="col-md-4">
                <div class="stat-box">
                    <div class="number"><i class="fa-solid fa-ticket-simple text-success me-1"></i> 4 Operations</div>
                    <div class="label">Block &bull; Reserve &bull; Reschedule &bull; Cancel</div>
                    <p class="small text-muted mt-2 mb-0">Complete transaction lifecycle for registered airline passengers.</p>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
