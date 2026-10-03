<%@ Page Title="Administrative Operations Console - AeroFly ARS" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeFile="AdminDashboard.aspx.cs" Inherits="AdminDashboard" EnableEventValidation="false" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .admin-hero {
            background: linear-gradient(135deg, #1e1e2f 0%, #2d2d44 100%);
            border-radius: 1rem;
            color: #fff;
            padding: 2rem 2.5rem;
            margin-bottom: 2rem;
            position: relative;
            overflow: hidden;
            border-left: 6px solid #e11d48;
        }
        .admin-hero h1, .admin-hero h2, .admin-hero .display-6, .admin-hero-title {
            color: #ffffff !important;
            text-shadow: 0 2px 12px rgba(0, 0, 0, 0.6) !important;
        }
        .admin-hero::after {
            content: "\f4fe";
            font-family: "Font Awesome 6 Free";
            font-weight: 900;
            position: absolute;
            right: 25px;
            bottom: -30px;
            font-size: 9rem;
            color: rgba(255, 255, 255, 0.04);
            pointer-events: none;
        }
        .kpi-card {
            border-radius: 0.75rem;
            background: #ffffff;
            border: 1px solid #e2e8f0;
            padding: 1.25rem;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
            height: 100%;
        }
        .kpi-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.08);
        }
        .kpi-icon {
            width: 48px;
            height: 48px;
            border-radius: 0.5rem;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
        }
        .nav-admin-tabs .nav-link {
            font-weight: 600;
            color: #475569;
            padding: 0.75rem 1.25rem;
            border: none;
            border-bottom: 3px solid transparent;
            border-radius: 0;
            background: transparent;
        }
        .nav-admin-tabs .nav-link.active {
            color: #e11d48;
            border-bottom: 3px solid #e11d48;
            background: transparent;
        }
        .table-admin th {
            font-size: 0.8rem;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            background-color: #f8fafc;
            color: #475569;
            border-bottom: 2px solid #e2e8f0;
        }
        .modal-header-custom {
            background-color: #1e1e2f;
            color: #ffffff;
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container-fluid px-lg-5 py-4">
        
        <!-- Breadcrumbs -->
        <nav aria-label="breadcrumb" class="mb-3">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="Default.aspx">Home</a></li>
                <li class="breadcrumb-item"><a href="Dashboard.aspx">User Dashboard</a></li>
                <li class="breadcrumb-item active" aria-current="page">Admin / Clerk Control Console</li>
            </ol>
        </nav>

        <!-- Unauthorized Warning Panel (If logged in as non-admin) -->
        <asp:Panel ID="pnlAccessDenied" runat="server" Visible="false" CssClass="alert alert-danger shadow-sm p-4 mb-4 rounded-3 border-danger">
            <div class="d-flex align-items-start">
                <i class="fa-solid fa-shield-halved fa-3x text-danger me-3"></i>
                <div class="flex-grow-1">
                    <h4 class="fw-bold text-danger mb-1"><i class="fa-solid fa-lock me-1"></i> Administrator Access Privileges Required</h4>
                    <p class="mb-2">
                        You are currently logged in as <strong><asp:Literal ID="litCurrentRoleUser" runat="server"></asp:Literal></strong> with role 
                        <span class="badge bg-secondary"><asp:Literal ID="litCurrentRoleBadge" runat="server"></asp:Literal></span>. 
                        Only accounts with <strong>Admin</strong> or <strong>Clerk</strong> credentials have clearance to view flight manifests, modify schedule timings, adjust seat allocations, and manage user accounts.
                    </p>
                    <div class="d-flex gap-2 mt-3 flex-wrap">
                        <asp:Button ID="btnDemoAdminLogin" runat="server" Text="Log in as Administrator (admin / Admin@123)" CssClass="btn btn-danger fw-bold" OnClick="btnDemoAdminLogin_Click" />
                        <a href="Dashboard.aspx" class="btn btn-outline-secondary"><i class="fa-solid fa-gauge-high me-1"></i> Return to Passenger Dashboard</a>
                    </div>
                </div>
            </div>
        </asp:Panel>

        <!-- MAIN AUTHORIZED ADMIN PORTAL -->
        <asp:Panel ID="pnlAdminAuthorized" runat="server" Visible="true">
            
            <!-- Hero Header -->
            <div class="admin-hero shadow-sm">
                <div class="row align-items-center">
                    <div class="col-lg-8">
                        <span class="badge bg-danger text-white px-3 py-1 rounded-pill fw-bold text-uppercase mb-2">
                            <i class="fa-solid fa-screwdriver-wrench me-1"></i> Central Operations Command
                        </span>
                        <h1 class="display-6 fw-bold mb-2 text-white admin-hero-title" style="color: #ffffff !important; text-shadow: 0 2px 12px rgba(0,0,0,0.6);">AeroFly Central Operations Command</h1>
                        <p class="text-white-50 mb-0 fs-6">
                            Source-derived administrative functions: manage commercial flights, dispatch schedules, last-minute delay advisories, passenger reservations, user profiles, and live seat inventories.
                        </p>
                    </div>
                    <div class="col-lg-4 text-lg-end mt-3 mt-lg-0">
                        <span class="badge bg-success-subtle text-success border border-success px-3 py-2 fs-6">
                            <i class="fa-solid fa-user-shield me-1"></i> Authenticated: <strong><asp:Literal ID="litAdminUsername" runat="server"></asp:Literal></strong>
                        </span>
                    </div>
                </div>
            </div>

            <!-- Global Feedback Alert Banner -->
            <asp:Panel ID="pnlAdminAlert" runat="server" Visible="false" CssClass="alert alert-success alert-dismissible fade show shadow-sm mb-4" role="alert">
                <div class="d-flex align-items-center">
                    <i class="fa-solid fa-circle-check fa-2x me-3"></i>
                    <div>
                        <asp:Literal ID="litAdminAlertMessage" runat="server"></asp:Literal>
                    </div>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </asp:Panel>

            <!-- 5 KPI Stat Metrics Cards -->
            <div class="row g-3 mb-4">
                <div class="col-xl-2 col-md-4 col-sm-6">
                    <div class="kpi-card shadow-sm">
                        <div class="d-flex align-items-center justify-content-between mb-2">
                            <span class="small text-muted text-uppercase fw-bold">Active Flights</span>
                            <div class="kpi-icon bg-primary-subtle text-primary"><i class="fa-solid fa-plane"></i></div>
                        </div>
                        <h3 class="fw-bold mb-0 text-dark"><asp:Literal ID="litKpiTotalFlights" runat="server">0</asp:Literal></h3>
                        <small class="text-muted">Serviced schedules</small>
                    </div>
                </div>

                <div class="col-xl-2 col-md-4 col-sm-6">
                    <div class="kpi-card shadow-sm">
                        <div class="d-flex align-items-center justify-content-between mb-2">
                            <span class="small text-muted text-uppercase fw-bold">Reservations</span>
                            <div class="kpi-icon bg-success-subtle text-success"><i class="fa-solid fa-ticket"></i></div>
                        </div>
                        <h3 class="fw-bold mb-0 text-success"><asp:Literal ID="litKpiTotalReservations" runat="server">0</asp:Literal></h3>
                        <small class="text-muted"><asp:Literal ID="litKpiConfirmedCount" runat="server">0</asp:Literal> Confirmed &bull; <asp:Literal ID="litKpiBlockedCount" runat="server">0</asp:Literal> Blocked</small>
                    </div>
                </div>

                <div class="col-xl-2 col-md-4 col-sm-6">
                    <div class="kpi-card shadow-sm">
                        <div class="d-flex align-items-center justify-content-between mb-2">
                            <span class="small text-muted text-uppercase fw-bold">Cancelled</span>
                            <div class="kpi-icon bg-danger-subtle text-danger"><i class="fa-solid fa-ban"></i></div>
                        </div>
                        <h3 class="fw-bold mb-0 text-danger"><asp:Literal ID="litKpiCancelledCount" runat="server">0</asp:Literal></h3>
                        <small class="text-muted">Refunded / released</small>
                    </div>
                </div>

                <div class="col-xl-2 col-md-4 col-sm-6">
                    <div class="kpi-card shadow-sm">
                        <div class="d-flex align-items-center justify-content-between mb-2">
                            <span class="small text-muted text-uppercase fw-bold">Registered Users</span>
                            <div class="kpi-icon bg-info-subtle text-info"><i class="fa-solid fa-users"></i></div>
                        </div>
                        <h3 class="fw-bold mb-0 text-dark"><asp:Literal ID="litKpiTotalUsers" runat="server">0</asp:Literal></h3>
                        <small class="text-muted">Customer profiles in DB</small>
                    </div>
                </div>

                <div class="col-xl-3 col-md-4 col-sm-6">
                    <div class="kpi-card shadow-sm">
                        <div class="d-flex align-items-center justify-content-between mb-2">
                            <span class="small text-muted text-uppercase fw-bold">Confirmed Gross Revenue</span>
                            <div class="kpi-icon bg-warning-subtle text-warning"><i class="fa-solid fa-sack-dollar"></i></div>
                        </div>
                        <h3 class="fw-bold mb-0 text-dark">PKR <asp:Literal ID="litKpiTotalRevenue" runat="server">0</asp:Literal></h3>
                        <small class="text-muted">Direct passenger sales</small>
                    </div>
                </div>

                <div class="col-xl-3 col-md-4 col-sm-6">
                    <div class="kpi-card shadow-sm">
                        <div class="d-flex align-items-center justify-content-between mb-2">
                            <span class="small text-muted text-uppercase fw-bold">Fleet Seat Occupancy</span>
                            <div class="kpi-icon bg-purple-subtle text-purple" style="background:#f3e8ff; color:#7e22ce;"><i class="fa-solid fa-chair"></i></div>
                        </div>
                        <h3 class="fw-bold mb-0 text-dark"><asp:Literal ID="litKpiOccupancyRate" runat="server">0%</asp:Literal></h3>
                        <small class="text-muted"><asp:Literal ID="litKpiAvailSeats" runat="server">0</asp:Literal> available / <asp:Literal ID="litKpiTotalCap" runat="server">0</asp:Literal> total</small>
                    </div>
                </div>
            </div>

            <!-- Tabbed Navigation Bar for 5 Module Screens -->
            <div class="card border-0 shadow-sm rounded-3 overflow-hidden mb-4">
                <div class="card-header bg-white border-bottom p-0">
                    <ul class="nav nav-tabs nav-admin-tabs px-3" id="adminTabs" role="tablist">
                        <li class="nav-item" role="presentation">
                            <button class="nav-link active" id="tab-flights-btn" data-bs-toggle="tab" data-bs-target="#tab-flights" type="button" role="tab">
                                <i class="fa-solid fa-plane-departure me-2"></i>1. Flights Management
                            </button>
                        </li>
                        <li class="nav-item" role="presentation">
                            <button class="nav-link" id="tab-schedules-btn" data-bs-toggle="tab" data-bs-target="#tab-schedules" type="button" role="tab">
                                <i class="fa-solid fa-calendar-days me-2"></i>2. Schedules &amp; Timing Control
                            </button>
                        </li>
                        <li class="nav-item" role="presentation">
                            <button class="nav-link" id="tab-reservations-btn" data-bs-toggle="tab" data-bs-target="#tab-reservations" type="button" role="tab">
                                <i class="fa-solid fa-receipt me-2"></i>3. Reservations Overview
                            </button>
                        </li>
                        <li class="nav-item" role="presentation">
                            <button class="nav-link" id="tab-users-btn" data-bs-toggle="tab" data-bs-target="#tab-users" type="button" role="tab">
                                <i class="fa-solid fa-user-gear me-2"></i>4. Users &amp; Roles
                            </button>
                        </li>
                        <li class="nav-item" role="presentation">
                            <button class="nav-link" id="tab-seats-btn" data-bs-toggle="tab" data-bs-target="#tab-seats" type="button" role="tab">
                                <i class="fa-solid fa-chart-pie me-2"></i>5. Seat Availability Monitor
                            </button>
                        </li>
                    </ul>
                </div>

                <div class="card-body p-4 bg-light">
                    <div class="tab-content" id="adminTabsContent">
                        
                        <!-- ======================================================= -->
                        <!-- SCREEN 1: FLIGHTS MANAGEMENT -->
                        <!-- ======================================================= -->
                        <div class="tab-pane fade show active" id="tab-flights" role="tabpanel">
                            <div class="d-flex justify-content-between align-items-center mb-3 flex-wrap gap-2">
                                <div>
                                    <h4 class="fw-bold mb-0 text-dark"><i class="fa-solid fa-plane-departure text-primary me-2"></i> Commercial Flights Directory</h4>
                                    <p class="text-muted small mb-0">Create new flights, edit routes, fare tiers, and adjust fleet configurations.</p>
                                </div>
                                <button type="button" class="btn btn-primary fw-bold" data-bs-toggle="collapse" data-bs-target="#collapseAddFlight">
                                    <i class="fa-solid fa-plus me-1"></i> Add New Flight
                                </button>
                            </div>

                            <!-- Add / Edit Flight Collapse Form -->
                            <div class="collapse mb-4" id="collapseAddFlight">
                                <div class="card card-body border-0 shadow-sm p-4 bg-white border-start border-primary border-4">
                                    <h5 class="fw-bold mb-3 text-primary"><i class="fa-solid fa-pen-to-square me-2"></i> Add or Update Flight Record</h5>
                                    
                                    <asp:HiddenField ID="hfFlightId" runat="server" Value="" />
                                    
                                    <div class="row g-3">
                                        <div class="col-md-3">
                                            <label class="form-label fw-bold small text-muted">Flight Number</label>
                                            <asp:TextBox ID="txtFlightNumber" runat="server" CssClass="form-control text-uppercase" placeholder="e.g. PK-501"></asp:TextBox>
                                        </div>
                                        <div class="col-md-3">
                                            <label class="form-label fw-bold small text-muted">Operating Airline</label>
                                            <asp:TextBox ID="txtAirlineName" runat="server" CssClass="form-control" placeholder="e.g. AeroFly Pakistan"></asp:TextBox>
                                        </div>
                                        <div class="col-md-3">
                                            <label class="form-label fw-bold small text-muted">Origin City</label>
                                            <asp:TextBox ID="txtOriginCity" runat="server" CssClass="form-control" placeholder="e.g. Karachi"></asp:TextBox>
                                        </div>
                                        <div class="col-md-3">
                                            <label class="form-label fw-bold small text-muted">Destination City</label>
                                            <asp:TextBox ID="txtDestinationCity" runat="server" CssClass="form-control" placeholder="e.g. Islamabad"></asp:TextBox>
                                        </div>

                                        <div class="col-md-3">
                                            <label class="form-label fw-bold small text-muted">Departure Time</label>
                                            <asp:TextBox ID="txtDepartureTime" runat="server" TextMode="DateTimeLocal" CssClass="form-control"></asp:TextBox>
                                        </div>
                                        <div class="col-md-3">
                                            <label class="form-label fw-bold small text-muted">Arrival Time</label>
                                            <asp:TextBox ID="txtArrivalTime" runat="server" TextMode="DateTimeLocal" CssClass="form-control"></asp:TextBox>
                                        </div>
                                        <div class="col-md-2">
                                            <label class="form-label fw-bold small text-muted">Total Capacity</label>
                                            <asp:TextBox ID="txtTotalSeats" runat="server" TextMode="Number" CssClass="form-control" placeholder="180"></asp:TextBox>
                                        </div>
                                        <div class="col-md-2">
                                            <label class="form-label fw-bold small text-muted">Available Seats</label>
                                            <asp:TextBox ID="txtAvailableSeats" runat="server" TextMode="Number" CssClass="form-control" placeholder="180"></asp:TextBox>
                                        </div>
                                        <div class="col-md-2">
                                            <label class="form-label fw-bold small text-muted">Initial Status</label>
                                            <asp:DropDownList ID="ddlFlightStatus" runat="server" CssClass="form-select">
                                                <asp:ListItem Value="On-Time" Text="On-Time" />
                                                <asp:ListItem Value="Scheduled" Text="Scheduled" />
                                                <asp:ListItem Value="Delayed" Text="Delayed" />
                                                <asp:ListItem Value="Cancelled" Text="Cancelled" />
                                            </asp:DropDownList>
                                        </div>

                                        <div class="col-md-4">
                                            <label class="form-label fw-bold small text-muted">Economy Price (PKR)</label>
                                            <asp:TextBox ID="txtEconomyPrice" runat="server" CssClass="form-control" placeholder="15000"></asp:TextBox>
                                        </div>
                                        <div class="col-md-4">
                                            <label class="form-label fw-bold small text-muted">Business Price (PKR)</label>
                                            <asp:TextBox ID="txtBusinessPrice" runat="server" CssClass="form-control" placeholder="30000"></asp:TextBox>
                                        </div>
                                        <div class="col-md-4">
                                            <label class="form-label fw-bold small text-muted">First Class Price (PKR)</label>
                                            <asp:TextBox ID="txtFirstClassPrice" runat="server" CssClass="form-control" placeholder="45000"></asp:TextBox>
                                        </div>

                                        <div class="col-12 text-end pt-2">
                                            <asp:Button ID="btnSaveFlight" runat="server" Text="Save Flight Record" CssClass="btn btn-success fw-bold px-4" OnClick="btnSaveFlight_Click" />
                                            <asp:Button ID="btnCancelFlightForm" runat="server" Text="Reset Form" CssClass="btn btn-outline-secondary ms-2" OnClick="btnCancelFlightForm_Click" />
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Flights Table -->
                            <div class="table-responsive bg-white rounded-3 shadow-sm border">
                                <asp:GridView ID="gvFlights" runat="server" AutoGenerateColumns="false" CssClass="table table-hover align-middle mb-0 table-admin"
                                    DataKeyNames="FlightId" OnRowCommand="gvFlights_RowCommand">
                                    <Columns>
                                        <asp:BoundField DataField="FlightId" HeaderText="ID" ItemStyle-CssClass="fw-bold text-muted small" />
                                        <asp:TemplateField HeaderText="Flight #">
                                            <ItemTemplate>
                                                <strong class="text-primary"><%# Eval("FlightNumber") %></strong>
                                                <div class="small text-muted"><%# Eval("AirlineName") %></div>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Route">
                                            <ItemTemplate>
                                                <span class="badge bg-primary-subtle text-primary"><%# Eval("OriginCity") %></span>
                                                <i class="fa-solid fa-arrow-right mx-1 text-muted"></i>
                                                <span class="badge bg-danger-subtle text-danger"><%# Eval("DestinationCity") %></span>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Schedule">
                                            <ItemTemplate>
                                                <div class="small fw-semibold"><%# Convert.ToDateTime(Eval("DepartureTime")).ToString("dd-MMM-yyyy hh:mm tt") %></div>
                                                <div class="small text-muted"><%# Convert.ToDateTime(Eval("ArrivalTime")).ToString("dd-MMM-yyyy hh:mm tt") %></div>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Seats">
                                            <ItemTemplate>
                                                <span class="badge bg-info-subtle text-dark fw-bold">
                                                    <%# Eval("AvailableSeats") %> / <%# Eval("TotalSeats") %>
                                                </span>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Fares (E / B / F)">
                                            <ItemTemplate>
                                                <div class="small font-monospace">
                                                    PKR <%# string.Format("{0:N0}", Eval("EconomyPrice")) %> &bull;
                                                    PKR <%# string.Format("{0:N0}", Eval("BusinessPrice")) %> &bull;
                                                    PKR <%# string.Format("{0:N0}", Eval("FirstClassPrice")) %>
                                                </div>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Status">
                                            <ItemTemplate>
                                                <span class='badge <%# Eval("Status").ToString() == "On-Time" ? "bg-success" : (Eval("Status").ToString() == "Delayed" ? "bg-danger" : "bg-warning text-dark") %>'>
                                                    <%# Eval("Status") %>
                                                </span>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Actions" ItemStyle-CssClass="text-end">
                                            <ItemTemplate>
                                                <asp:LinkButton ID="btnEdit" runat="server" CommandName="EditFlight" CommandArgument='<%# Eval("FlightId") %>' CssClass="btn btn-sm btn-outline-primary me-1" title="Edit Flight Details">
                                                    <i class="fa-solid fa-pencil"></i>
                                                </asp:LinkButton>
                                                <asp:LinkButton ID="btnDelete" runat="server" CommandName="DeleteFlight" CommandArgument='<%# Eval("FlightId") %>' CssClass="btn btn-sm btn-outline-danger" title="Delete Flight" OnClientClick="return confirm('Are you sure you want to permanently delete this flight?');">
                                                    <i class="fa-solid fa-trash-can"></i>
                                                </asp:LinkButton>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                </asp:GridView>
                            </div>
                        </div>

                        <!-- ======================================================= -->
                        <!-- SCREEN 2: SCHEDULES & FLIGHT TIMING CONTROL -->
                        <!-- ======================================================= -->
                        <div class="tab-pane fade" id="tab-schedules" role="tabpanel">
                            <div class="d-flex justify-content-between align-items-center mb-3 flex-wrap gap-2">
                                <div>
                                    <h4 class="fw-bold mb-0 text-dark"><i class="fa-solid fa-calendar-days text-primary me-2"></i> Schedules &amp; Flight Timing Control</h4>
                                    <p class="text-muted small mb-0">Adjust departure/arrival dates, simulate last-minute operational delays, and issue passenger advisories.</p>
                                </div>
                            </div>

                            <!-- Schedule Timing Edit Box -->
                            <asp:Panel ID="pnlScheduleEditor" runat="server" Visible="false" CssClass="card p-4 bg-white border-0 shadow-sm border-start border-warning border-4 mb-4">
                                <h5 class="fw-bold text-dark mb-3">
                                    <i class="fa-solid fa-clock-rotate-left text-warning me-2"></i> Modify Flight Timing: <asp:Literal ID="litScheduleFlightNo" runat="server"></asp:Literal>
                                </h5>
                                <asp:HiddenField ID="hfScheduleFlightId" runat="server" />

                                <div class="row g-3">
                                    <div class="col-md-3">
                                        <label class="form-label fw-bold small text-muted">Scheduled Departure</label>
                                        <asp:TextBox ID="txtSchedDepTime" runat="server" TextMode="DateTimeLocal" CssClass="form-control"></asp:TextBox>
                                    </div>
                                    <div class="col-md-3">
                                        <label class="form-label fw-bold small text-muted">Scheduled Arrival</label>
                                        <asp:TextBox ID="txtSchedArrTime" runat="server" TextMode="DateTimeLocal" CssClass="form-control"></asp:TextBox>
                                    </div>
                                    <div class="col-md-3">
                                        <label class="form-label fw-bold small text-muted">Revised Departure (Optional Delay)</label>
                                        <asp:TextBox ID="txtRevisedDepTime" runat="server" TextMode="DateTimeLocal" CssClass="form-control"></asp:TextBox>
                                    </div>
                                    <div class="col-md-3">
                                        <label class="form-label fw-bold small text-muted">Revised Arrival (Optional Delay)</label>
                                        <asp:TextBox ID="txtRevisedArrTime" runat="server" TextMode="DateTimeLocal" CssClass="form-control"></asp:TextBox>
                                    </div>

                                    <div class="col-md-4">
                                        <label class="form-label fw-bold small text-muted">Operational Flight Status</label>
                                        <asp:DropDownList ID="ddlScheduleStatus" runat="server" CssClass="form-select">
                                            <asp:ListItem Value="On-Time" Text="On-Time (Normal Schedule)" />
                                            <asp:ListItem Value="Delayed" Text="Delayed (Timing Revision)" />
                                            <asp:ListItem Value="Rescheduled" Text="Rescheduled" />
                                            <asp:ListItem Value="Cancelled" Text="Cancelled" />
                                        </asp:DropDownList>
                                    </div>
                                    <div class="col-md-8">
                                        <label class="form-label fw-bold small text-muted">Delay Reason / Dispatch Advisory</label>
                                        <asp:TextBox ID="txtTimingReason" runat="server" CssClass="form-control" placeholder="e.g. Dense fog at destination airport resulting in ATC hold"></asp:TextBox>
                                    </div>

                                    <div class="col-12 text-end pt-2">
                                        <asp:Button ID="btnUpdateSchedule" runat="server" Text="Apply Schedule Timing Update" CssClass="btn btn-warning text-dark fw-bold px-4" OnClick="btnUpdateSchedule_Click" />
                                        <asp:Button ID="btnCloseScheduleEditor" runat="server" Text="Close Editor" CssClass="btn btn-outline-secondary ms-2" OnClick="btnCloseScheduleEditor_Click" />
                                    </div>
                                </div>
                            </asp:Panel>

                            <!-- Schedules Grid -->
                            <div class="table-responsive bg-white rounded-3 shadow-sm border">
                                <asp:GridView ID="gvSchedules" runat="server" AutoGenerateColumns="false" CssClass="table table-hover align-middle mb-0 table-admin"
                                    DataKeyNames="FlightId" OnRowCommand="gvSchedules_RowCommand">
                                    <Columns>
                                        <asp:BoundField DataField="FlightNumber" HeaderText="Flight #" ItemStyle-CssClass="fw-bold text-primary" />
                                        <asp:TemplateField HeaderText="Route">
                                            <ItemTemplate>
                                                <%# Eval("OriginCity") %> &rarr; <%# Eval("DestinationCity") %>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Scheduled Times">
                                            <ItemTemplate>
                                                <div><i class="fa-solid fa-plane-departure text-muted me-1"></i> <%# Convert.ToDateTime(Eval("DepartureTime")).ToString("dd-MMM-yyyy hh:mm tt") %></div>
                                                <div><i class="fa-solid fa-plane-arrival text-muted me-1"></i> <%# Convert.ToDateTime(Eval("ArrivalTime")).ToString("dd-MMM-yyyy hh:mm tt") %></div>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Revised / Delay Timings">
                                            <ItemTemplate>
                                                <%# Eval("RevisedDepartureTime") != DBNull.Value && Eval("RevisedDepartureTime") != null ? 
                                                    "<div class='text-danger fw-bold'><i class='fa-solid fa-clock-rotate-left me-1'></i> " + Convert.ToDateTime(Eval("RevisedDepartureTime")).ToString("dd-MMM hh:mm tt") + "</div>" +
                                                    "<small class='text-muted d-block'>" + Server.HtmlEncode(Eval("TimingChangeReason").ToString()) + "</small>"
                                                    : "<span class='text-muted small'>None (On-Time)</span>" %>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Status">
                                            <ItemTemplate>
                                                <span class='badge <%# Eval("Status").ToString() == "On-Time" ? "bg-success" : (Eval("Status").ToString() == "Delayed" ? "bg-danger" : "bg-warning text-dark") %>'>
                                                    <%# Eval("Status") %>
                                                </span>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Action" ItemStyle-CssClass="text-end">
                                            <ItemTemplate>
                                                <asp:LinkButton ID="btnScheduleEdit" runat="server" CommandName="EditSchedule" CommandArgument='<%# Eval("FlightId") %>' CssClass="btn btn-sm btn-outline-warning text-dark fw-bold">
                                                    <i class="fa-solid fa-clock me-1"></i> Modify Timing / Delay
                                                </asp:LinkButton>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                </asp:GridView>
                            </div>
                        </div>

                        <!-- ======================================================= -->
                        <!-- SCREEN 3: RESERVATIONS OVERVIEW -->
                        <!-- ======================================================= -->
                        <div class="tab-pane fade" id="tab-reservations" role="tabpanel">
                            <div class="d-flex justify-content-between align-items-center mb-3 flex-wrap gap-2">
                                <div>
                                    <h4 class="fw-bold mb-0 text-dark"><i class="fa-solid fa-receipt text-primary me-2"></i> Reservations Overview &amp; Control</h4>
                                    <p class="text-muted small mb-0">Search, monitor, and override passenger bookings across all transaction types.</p>
                                </div>
                            </div>

                            <!-- Filter & Search Toolbar -->
                            <div class="card p-3 bg-white border-0 shadow-sm mb-4">
                                <div class="row g-3 align-items-end">
                                    <div class="col-md-3">
                                        <label class="form-label fw-bold small text-muted">Status Filter</label>
                                        <asp:DropDownList ID="ddlResFilter" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="btnFilterReservations_Click">
                                            <asp:ListItem Value="All" Text="All Bookings" />
                                            <asp:ListItem Value="Confirmed" Text="Confirmed Only" />
                                            <asp:ListItem Value="Blocked" Text="Blocked Only" />
                                            <asp:ListItem Value="Cancelled" Text="Cancelled Only" />
                                        </asp:DropDownList>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label fw-bold small text-muted">Search Keyword</label>
                                        <div class="input-group">
                                            <span class="input-group-text bg-light text-muted"><i class="fa-solid fa-magnifying-glass"></i></span>
                                            <asp:TextBox ID="txtResSearch" runat="server" CssClass="form-control" placeholder="Reference (CNF/BLK/CAN), passenger name, username, or flight..."></asp:TextBox>
                                        </div>
                                    </div>
                                    <div class="col-md-3">
                                        <asp:Button ID="btnFilterReservations" runat="server" Text="Search Records" CssClass="btn btn-primary w-100 fw-bold" OnClick="btnFilterReservations_Click" />
                                    </div>
                                </div>
                            </div>

                            <!-- Reservations Table -->
                            <div class="table-responsive bg-white rounded-3 shadow-sm border">
                                <asp:GridView ID="gvReservations" runat="server" AutoGenerateColumns="false" CssClass="table table-hover align-middle mb-0 table-admin"
                                    DataKeyNames="ReservationId" OnRowCommand="gvReservations_RowCommand">
                                    <Columns>
                                        <asp:TemplateField HeaderText="Reference">
                                            <ItemTemplate>
                                                <span class="font-monospace fw-bold text-primary"><%# Eval("BookingReference") %></span>
                                                <div class="small text-muted"><%# Convert.ToDateTime(Eval("BookingDate")).ToString("dd-MMM-yyyy hh:mm tt") %></div>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Passenger & User">
                                            <ItemTemplate>
                                                <strong class="text-dark"><%# Eval("PassengerName") %></strong>
                                                <div class="small text-muted">Account: <%# Eval("CustomerUsername") %></div>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Flight & Route">
                                            <ItemTemplate>
                                                <span class="badge bg-secondary"><%# Eval("FlightNumber") %></span>
                                                <div class="small"><%# Eval("OriginCity") %> &rarr; <%# Eval("DestinationCity") %></div>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Class & Fare">
                                            <ItemTemplate>
                                                <div><%# Eval("SeatClass") %></div>
                                                <div class="fw-bold text-success">PKR <%# string.Format("{0:N2}", Eval("TotalPrice")) %></div>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Status">
                                            <ItemTemplate>
                                                <span class='badge <%# Eval("Status").ToString() == "Confirmed" ? "bg-success" : (Eval("Status").ToString() == "Blocked" ? "bg-warning text-dark" : "bg-danger") %>'>
                                                    <%# Eval("Status") %>
                                                </span>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Admin Override" ItemStyle-CssClass="text-end">
                                            <ItemTemplate>
                                                <asp:LinkButton ID="btnConfirmRes" runat="server" CommandName="ConfirmBooking" CommandArgument='<%# Eval("ReservationId") %>' CssClass="btn btn-sm btn-outline-success me-1" Visible='<%# Eval("Status").ToString() == "Blocked" %>'>
                                                    <i class="fa-solid fa-circle-check"></i> Confirm
                                                </asp:LinkButton>
                                                <asp:LinkButton ID="btnCancelRes" runat="server" CommandName="CancelBooking" CommandArgument='<%# Eval("ReservationId") %>' CssClass="btn btn-sm btn-outline-danger" Visible='<%# Eval("Status").ToString() != "Cancelled" %>' OnClientClick="return confirm('Override & cancel this reservation?');">
                                                    <i class="fa-solid fa-ban"></i> Cancel
                                                </asp:LinkButton>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                </asp:GridView>
                            </div>
                        </div>

                        <!-- ======================================================= -->
                        <!-- SCREEN 4: USERS & ROLES -->
                        <!-- ======================================================= -->
                        <div class="tab-pane fade" id="tab-users" role="tabpanel">
                            <div class="d-flex justify-content-between align-items-center mb-3 flex-wrap gap-2">
                                <div>
                                    <h4 class="fw-bold mb-0 text-dark"><i class="fa-solid fa-user-gear text-primary me-2"></i> User Directory &amp; Role Assignments</h4>
                                    <p class="text-muted small mb-0">Manage customer accounts, assign administrative / clerk permissions, and calibrate SkyMiles.</p>
                                </div>
                            </div>

                            <!-- Search Users Box -->
                            <div class="card p-3 bg-white border-0 shadow-sm mb-4">
                                <div class="row g-2 align-items-center">
                                    <div class="col-md-9">
                                        <div class="input-group">
                                            <span class="input-group-text bg-light text-muted"><i class="fa-solid fa-magnifying-glass"></i></span>
                                            <asp:TextBox ID="txtUserSearch" runat="server" CssClass="form-control" placeholder="Search by username, full name, or email..."></asp:TextBox>
                                        </div>
                                    </div>
                                    <div class="col-md-3">
                                        <asp:Button ID="btnSearchUsers" runat="server" Text="Filter Users" CssClass="btn btn-primary w-100 fw-bold" OnClick="btnSearchUsers_Click" />
                                    </div>
                                </div>
                            </div>

                            <!-- Users Grid -->
                            <div class="table-responsive bg-white rounded-3 shadow-sm border">
                                <asp:GridView ID="gvUsers" runat="server" AutoGenerateColumns="false" CssClass="table table-hover align-middle mb-0 table-admin"
                                    DataKeyNames="UserId" OnRowCommand="gvUsers_RowCommand">
                                    <Columns>
                                        <asp:BoundField DataField="UserId" HeaderText="ID" ItemStyle-CssClass="fw-bold text-muted small" />
                                        <asp:TemplateField HeaderText="User Account">
                                            <ItemTemplate>
                                                <strong class="text-dark"><%# Eval("Username") %></strong>
                                                <div class="small text-muted"><%# Eval("FirstName") %> <%# Eval("LastName") %></div>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Contact Info">
                                            <ItemTemplate>
                                                <div><%# Eval("Email") %></div>
                                                <div class="small text-muted"><%# Eval("PhoneNumber") %></div>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="SkyMiles">
                                            <ItemTemplate>
                                                <span class="badge bg-warning-subtle text-warning-emphasis border border-warning fw-bold">
                                                    <i class="fa-solid fa-award me-1"></i> <%# Eval("SkyMiles") %>
                                                </span>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Role">
                                            <ItemTemplate>
                                                <span class='badge <%# Eval("Role").ToString() == "Admin" ? "bg-danger" : (Eval("Role").ToString() == "Clerk" ? "bg-info text-dark" : "bg-secondary") %>'>
                                                    <%# Eval("Role") %>
                                                </span>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Role Management" ItemStyle-CssClass="text-end">
                                            <ItemTemplate>
                                                <asp:LinkButton ID="btnMakeAdmin" runat="server" CommandName="SetRoleAdmin" CommandArgument='<%# Eval("UserId") %>' CssClass="btn btn-sm btn-outline-danger me-1" title="Promote to Administrator">
                                                    <i class="fa-solid fa-shield-halved"></i> Admin
                                                </asp:LinkButton>
                                                <asp:LinkButton ID="btnMakeClerk" runat="server" CommandName="SetRoleClerk" CommandArgument='<%# Eval("UserId") %>' CssClass="btn btn-sm btn-outline-info me-1" title="Assign Clerk Privileges">
                                                    <i class="fa-solid fa-user-tie"></i> Clerk
                                                </asp:LinkButton>
                                                <asp:LinkButton ID="btnMakeUser" runat="server" CommandName="SetRoleUser" CommandArgument='<%# Eval("UserId") %>' CssClass="btn btn-sm btn-outline-secondary" title="Reset to Standard Passenger">
                                                    <i class="fa-solid fa-user"></i> User
                                                </asp:LinkButton>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                </asp:GridView>
                            </div>
                        </div>

                        <!-- ======================================================= -->
                        <!-- SCREEN 5: SEAT AVAILABILITY MONITOR -->
                        <!-- ======================================================= -->
                        <div class="tab-pane fade" id="tab-seats" role="tabpanel">
                            <div class="d-flex justify-content-between align-items-center mb-3 flex-wrap gap-2">
                                <div>
                                    <h4 class="fw-bold mb-0 text-dark"><i class="fa-solid fa-chart-pie text-primary me-2"></i> Fleet Seat Availability &amp; Occupancy Monitor</h4>
                                    <p class="text-muted small mb-0">Live visual occupancy rates and direct seat inventory calibration.</p>
                                </div>
                            </div>

                            <!-- Quick Seat Calibrator Box -->
                            <asp:Panel ID="pnlSeatCalibrator" runat="server" Visible="false" CssClass="card p-4 bg-white border-0 shadow-sm border-start border-info border-4 mb-4">
                                <h5 class="fw-bold text-dark mb-2">
                                    <i class="fa-solid fa-sliders text-info me-2"></i> Calibrate Seat Inventory for: <asp:Literal ID="litSeatFlightNo" runat="server"></asp:Literal>
                                </h5>
                                <asp:HiddenField ID="hfSeatFlightId" runat="server" />
                                <div class="row g-3 align-items-end">
                                    <div class="col-md-4">
                                        <label class="form-label fw-bold small text-muted">New Available Seats</label>
                                        <asp:TextBox ID="txtNewAvailableSeats" runat="server" TextMode="Number" CssClass="form-control form-control-lg"></asp:TextBox>
                                    </div>
                                    <div class="col-md-8">
                                        <asp:Button ID="btnSaveSeatInventory" runat="server" Text="Update Seat Inventory" CssClass="btn btn-info text-white fw-bold px-4" OnClick="btnSaveSeatInventory_Click" />
                                        <asp:Button ID="btnCloseSeatCalibrator" runat="server" Text="Cancel" CssClass="btn btn-outline-secondary ms-2" OnClick="btnCloseSeatCalibrator_Click" />
                                    </div>
                                </div>
                            </asp:Panel>

                            <!-- Seat Availability Table -->
                            <div class="table-responsive bg-white rounded-3 shadow-sm border">
                                <asp:GridView ID="gvSeatAvailability" runat="server" AutoGenerateColumns="false" CssClass="table table-hover align-middle mb-0 table-admin"
                                    DataKeyNames="FlightId" OnRowCommand="gvSeatAvailability_RowCommand">
                                    <Columns>
                                        <asp:BoundField DataField="FlightNumber" HeaderText="Flight #" ItemStyle-CssClass="fw-bold text-primary" />
                                        <asp:TemplateField HeaderText="Route">
                                            <ItemTemplate>
                                                <%# Eval("OriginCity") %> &rarr; <%# Eval("DestinationCity") %>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Total Capacity">
                                            <ItemTemplate>
                                                <span class="fw-bold"><%# Eval("TotalSeats") %> seats</span>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Available">
                                            <ItemTemplate>
                                                <span class="badge bg-success-subtle text-success fs-6"><%# Eval("AvailableSeats") %></span>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Booked">
                                            <ItemTemplate>
                                                <span class="badge bg-secondary-subtle text-secondary fs-6"><%# Eval("BookedSeats") %></span>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Occupancy %" ItemStyle-Width="250px">
                                            <ItemTemplate>
                                                <div class="d-flex align-items-center gap-2">
                                                    <div class="progress flex-grow-1" style="height: 12px;">
                                                        <div class="progress-bar <%# Convert.ToDouble(Eval("OccupancyPercentage")) > 75 ? "bg-danger" : (Convert.ToDouble(Eval("OccupancyPercentage")) > 40 ? "bg-warning" : "bg-success") %>" 
                                                             role="progressbar" 
                                                             style='<%# "width: " + Eval("OccupancyPercentage") + "%;" %>' 
                                                             aria-valuenow='<%# Eval("OccupancyPercentage") %>' 
                                                             aria-valuemin="0" 
                                                             aria-valuemax="100">
                                                        </div>
                                                    </div>
                                                    <span class="small fw-bold"><%# Eval("OccupancyPercentage") %>%</span>
                                                </div>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Actions" ItemStyle-CssClass="text-end">
                                            <ItemTemplate>
                                                <asp:LinkButton ID="btnCalibrate" runat="server" CommandName="CalibrateSeats" CommandArgument='<%# Eval("FlightId") %>' CssClass="btn btn-sm btn-outline-info">
                                                    <i class="fa-solid fa-sliders me-1"></i> Calibrate
                                                </asp:LinkButton>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                </asp:GridView>
                            </div>
                        </div>

                    </div>
                </div>
            </div>

        </asp:Panel>
    </div>

    <!-- Script to maintain active tab on postback or from URL query parameter ?tab=... -->
    <script>
        document.addEventListener("DOMContentLoaded", function () {
            const urlParams = new URLSearchParams(window.location.search);
            const activeTab = urlParams.get('tab');
            if (activeTab) {
                const triggerEl = document.querySelector('#tab-' + activeTab + '-btn');
                if (triggerEl) {
                    const tab = new bootstrap.Tab(triggerEl);
                    tab.show();
                }
            }

            // Update URL hash/param when tab changes
            const tabButtons = document.querySelectorAll('#adminTabs button[data-bs-toggle="tab"]');
            tabButtons.forEach(btn => {
                btn.addEventListener('shown.bs.tab', function (event) {
                    const targetId = event.target.getAttribute('data-bs-target').replace('#tab-', '');
                    const newUrl = new URL(window.location);
                    newUrl.searchParams.set('tab', targetId);
                    window.history.replaceState({}, '', newUrl);
                });
            });
        });
    </script>
</asp:Content>
