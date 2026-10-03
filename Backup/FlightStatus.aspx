<%@ Page Title="Flight Status & Details - AeroFly Airline Reservation System" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeFile="FlightStatus.aspx.cs" Inherits="FlightStatus" EnableEventValidation="false" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .flight-status-hero {
            background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%);
            border-radius: 1rem;
            color: #fff;
            padding: 2rem 2.5rem;
            margin-bottom: 2rem;
            position: relative;
            overflow: hidden;
        }
        .flight-status-hero::after {
            content: "\f072";
            font-family: "Font Awesome 6 Free";
            font-weight: 900;
            position: absolute;
            right: 20px;
            bottom: -30px;
            font-size: 10rem;
            color: rgba(255, 255, 255, 0.04);
            pointer-events: none;
        }
        .time-box {
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            border-radius: 0.75rem;
            padding: 1.25rem;
            text-align: center;
        }
        .time-display {
            font-size: 2.2rem;
            font-weight: 800;
            color: #0f172a;
            letter-spacing: -0.5px;
            line-height: 1.1;
        }
        .time-date {
            font-size: 0.95rem;
            color: #64748b;
            font-weight: 600;
        }
        .time-revised {
            color: #dc2626 !important;
        }
        .time-original-striked {
            text-decoration: line-through;
            color: #94a3b8;
            font-size: 1.1rem;
            font-weight: 600;
        }
        .status-badge-ontime {
            background-color: #dcfce7;
            color: #166534;
            border: 1px solid #86efac;
            font-weight: 700;
            padding: 0.5rem 1rem;
            border-radius: 2rem;
            display: inline-flex;
            align-items: center;
            font-size: 0.95rem;
        }
        .status-badge-delayed {
            background-color: #fee2e2;
            color: #991b1b;
            border: 1px solid #fca5a5;
            font-weight: 700;
            padding: 0.5rem 1rem;
            border-radius: 2rem;
            display: inline-flex;
            align-items: center;
            font-size: 0.95rem;
        }
        .route-pill {
            background: rgba(255, 255, 255, 0.15);
            border: 1px solid rgba(255, 255, 255, 0.25);
            border-radius: 2rem;
            padding: 0.4rem 1rem;
            font-size: 0.85rem;
            font-weight: 600;
            color: #f8fafc;
        }
        .quick-tag {
            cursor: pointer;
            transition: all 0.2s ease;
        }
        .quick-tag:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1);
        }
        .info-metric-card {
            border-radius: 0.75rem;
            background: #ffffff;
            border: 1px solid #e2e8f0;
            padding: 1rem;
            height: 100%;
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container py-4">
        <!-- Breadcrumbs -->
        <nav aria-label="breadcrumb" class="mb-3">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="Default.aspx">Home</a></li>
                <li class="breadcrumb-item"><a href="SearchFlights.aspx">Flights</a></li>
                <li class="breadcrumb-item active" aria-current="page">Flight Status &amp; Public Details</li>
            </ol>
        </nav>

        <!-- Hero Header -->
        <div class="flight-status-hero shadow-sm">
            <div class="row align-items-center">
                <div class="col-lg-8">
                    <span class="badge bg-warning text-dark px-3 py-1 rounded-pill fw-bold text-uppercase mb-2">
                        <i class="fa-solid fa-earth-americas me-1"></i> Phase 12 &bull; Public Flight Details
                    </span>
                    <h1 class="display-6 fw-bold mb-2">Real-Time Flight Schedule &amp; Status</h1>
                    <p class="text-white-50 mb-0 fs-6">
                        Query live departure times, arrival times, route details, and last-minute schedule updates for any flight.
                        <strong>Open to all registered passengers and guest visitors without login.</strong>
                    </p>
                </div>
                <div class="col-lg-4 text-lg-end mt-3 mt-lg-0">
                    <div class="d-inline-flex align-items-center route-pill">
                        <i class="fa-solid fa-shield-heart text-warning me-2"></i>
                        <span>No Login Required &bull; Public Access</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- Search Form Card -->
        <div class="card border-0 shadow-sm rounded-3 mb-4">
            <div class="card-body p-4">
                <h5 class="fw-bold text-dark mb-3">
                    <i class="fa-solid fa-magnifying-glass text-primary me-2"></i> Find Flight Schedule
                </h5>

                <div class="row g-3 align-items-end">
                    <div class="col-md-5">
                        <label class="form-label fw-bold small text-uppercase text-muted">
                            <i class="fa-solid fa-plane text-primary me-1"></i> Flight Number <span class="text-danger">*</span>
                        </label>
                        <div class="input-group">
                            <span class="input-group-text bg-light text-muted fw-bold"><i class="fa-solid fa-hashtag"></i></span>
                            <asp:TextBox ID="txtFlightNumber" runat="server" CssClass="form-control form-control-lg fw-bold text-uppercase" placeholder="e.g. PK-301, PK-302, EK-007"></asp:TextBox>
                        </div>
                    </div>

                    <div class="col-md-4">
                        <label class="form-label fw-bold small text-uppercase text-muted">
                            <i class="fa-solid fa-calendar-day text-primary me-1"></i> Departure Date <small class="text-muted fw-normal">(Optional)</small>
                        </label>
                        <asp:TextBox ID="txtFlightDate" runat="server" TextMode="Date" CssClass="form-control form-control-lg"></asp:TextBox>
                    </div>

                    <div class="col-md-3">
                        <asp:Button ID="btnSearchFlight" runat="server" Text="Check Details" CssClass="btn btn-primary btn-lg w-100 fw-bold" OnClick="btnSearchFlight_Click" />
                    </div>
                </div>

                <!-- Quick Select Badges -->
                <div class="mt-3 pt-3 border-top d-flex align-items-center flex-wrap gap-2">
                    <span class="small text-muted fw-semibold me-1"><i class="fa-solid fa-bolt text-warning me-1"></i> Quick Lookups:</span>
                    <a href="FlightStatus.aspx?flight=PK-301" class="badge bg-light text-dark border quick-tag py-2 px-3 text-decoration-none">
                        <i class="fa-solid fa-plane me-1 text-primary"></i> PK-301 (Karachi &rarr; Islamabad)
                    </a>
                    <a href="FlightStatus.aspx?flight=PK-302" class="badge bg-light text-dark border quick-tag py-2 px-3 text-decoration-none">
                        <i class="fa-solid fa-plane me-1 text-primary"></i> PK-302 (Islamabad &rarr; Karachi)
                    </a>
                    <a href="FlightStatus.aspx?flight=EK-007" class="badge bg-light text-dark border quick-tag py-2 px-3 text-decoration-none">
                        <i class="fa-solid fa-plane me-1 text-primary"></i> EK-007 (Karachi &rarr; Dubai)
                    </a>
                    <a href="FlightStatus.aspx?flight=TK-708" class="badge bg-light text-dark border quick-tag py-2 px-3 text-decoration-none">
                        <i class="fa-solid fa-plane me-1 text-primary"></i> TK-708 (Islamabad &rarr; London)
                    </a>
                </div>
            </div>
        </div>

        <!-- Alert Panel (Errors / Not Found) -->
        <asp:Panel ID="pnlAlert" runat="server" Visible="false" CssClass="alert alert-danger alert-dismissible fade show shadow-sm" role="alert">
            <div class="d-flex align-items-center">
                <i class="fa-solid fa-circle-exclamation fa-2x me-3"></i>
                <div>
                    <h6 class="fw-bold mb-1">Flight Not Found</h6>
                    <asp:Literal ID="litAlertMessage" runat="server"></asp:Literal>
                </div>
            </div>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </asp:Panel>

        <!-- RESULTS SECTION (Public Flight Details) -->
        <asp:Panel ID="pnlFlightResults" runat="server" Visible="false">
            
            <!-- Timing Change / Delay Advisory Alert -->
            <asp:Panel ID="pnlDelayAdvisory" runat="server" Visible="false" CssClass="alert alert-warning border-warning shadow-sm mb-4">
                <div class="d-flex align-items-start">
                    <span class="badge bg-danger p-2 fs-5 me-3"><i class="fa-solid fa-triangle-exclamation"></i></span>
                    <div>
                        <div class="d-flex align-items-center gap-2 flex-wrap mb-1">
                            <h5 class="fw-bold text-danger mb-0">Schedule Timing Advisory Notice</h5>
                            <span class="badge bg-danger"><asp:Literal ID="litTimingDifferenceBadge" runat="server"></asp:Literal></span>
                        </div>
                        <p class="mb-1 text-dark">
                            The airline operations team has updated the flight schedule timings for this service.
                            Please review the revised departure and arrival times below.
                        </p>
                        <small class="text-muted"><i class="fa-solid fa-circle-info text-primary me-1"></i> <strong>Reason:</strong> <asp:Literal ID="litTimingReason" runat="server"></asp:Literal></small>
                    </div>
                </div>
            </asp:Panel>

            <!-- Main Flight Details Card -->
            <div class="card border-0 shadow-sm rounded-3 overflow-hidden mb-4">
                
                <!-- Card Header with Flight & Airline Info -->
                <div class="card-header bg-dark text-white p-4">
                    <div class="row align-items-center gy-3">
                        <div class="col-md-7">
                            <div class="d-flex align-items-center gap-3">
                                <div class="bg-primary text-white p-3 rounded-3">
                                    <i class="fa-solid fa-plane-up fa-2x"></i>
                                </div>
                                <div>
                                    <div class="d-flex align-items-center gap-2 flex-wrap">
                                        <h3 class="fw-bold mb-0 text-white"><asp:Literal ID="litFlightNumber" runat="server"></asp:Literal></h3>
                                        <asp:Literal ID="litStatusBadge" runat="server"></asp:Literal>
                                    </div>
                                    <span class="text-white-50 fs-6"><asp:Literal ID="litAirlineName" runat="server"></asp:Literal></span>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-5 text-md-end">
                            <span class="badge bg-light text-dark px-3 py-2 fs-6">
                                <i class="fa-solid fa-clock me-1 text-primary"></i> Duration: <strong class="text-primary"><asp:Literal ID="litFlightDuration" runat="server"></asp:Literal></strong>
                            </span>
                        </div>
                    </div>
                </div>

                <!-- Main Departure & Arrival Section -->
                <div class="card-body p-4">
                    
                    <!-- Route Banner & Timings -->
                    <div class="row g-4 align-items-center mb-4">
                        
                        <!-- DEPARTURE TIME BOX -->
                        <div class="col-lg-5">
                            <div class="time-box shadow-sm">
                                <span class="badge bg-primary px-3 py-1 rounded-pill text-uppercase fw-bold mb-2">
                                    <i class="fa-solid fa-plane-departure me-1"></i> Departure Details
                                </span>
                                <div class="fs-4 fw-bold text-primary mb-1"><asp:Literal ID="litOriginCity" runat="server"></asp:Literal></div>
                                
                                <!-- Departure Time (Scheduled & Revised) -->
                                <asp:Panel ID="pnlNormalDeparture" runat="server" Visible="true">
                                    <div class="time-display my-2"><asp:Literal ID="litDepartureTime" runat="server"></asp:Literal></div>
                                    <div class="time-date"><i class="fa-solid fa-calendar-day me-1"></i> <asp:Literal ID="litDepartureDate" runat="server"></asp:Literal></div>
                                </asp:Panel>

                                <asp:Panel ID="pnlRevisedDeparture" runat="server" Visible="false">
                                    <div class="time-original-striked"><asp:Literal ID="litOriginalDepTime" runat="server"></asp:Literal></div>
                                    <div class="time-display time-revised my-1"><i class="fa-solid fa-clock-rotate-left me-1"></i> <asp:Literal ID="litRevisedDepTime" runat="server"></asp:Literal></div>
                                    <div class="time-date text-danger fw-bold"><i class="fa-solid fa-calendar-day me-1"></i> <asp:Literal ID="litRevisedDepDate" runat="server"></asp:Literal> (Updated)</div>
                                </asp:Panel>
                            </div>
                        </div>

                        <!-- Route Flight Path Divider -->
                        <div class="col-lg-2 text-center py-2">
                            <div class="d-none d-lg-block">
                                <i class="fa-solid fa-plane text-primary fa-2x"></i>
                                <div class="mt-2 text-muted fw-bold small text-uppercase letter-spacing-1">Direct Flight</div>
                                <div class="border-top my-2 mx-auto" style="width: 80%;"></div>
                                <span class="badge bg-secondary-subtle text-secondary border">Non-Stop</span>
                            </div>
                            <div class="d-lg-none my-2">
                                <i class="fa-solid fa-arrow-down text-primary fa-2x"></i>
                            </div>
                        </div>

                        <!-- ARRIVAL TIME BOX -->
                        <div class="col-lg-5">
                            <div class="time-box shadow-sm">
                                <span class="badge bg-danger px-3 py-1 rounded-pill text-uppercase fw-bold mb-2">
                                    <i class="fa-solid fa-plane-arrival me-1"></i> Arrival Details
                                </span>
                                <div class="fs-4 fw-bold text-danger mb-1"><asp:Literal ID="litDestinationCity" runat="server"></asp:Literal></div>

                                <!-- Arrival Time (Scheduled & Revised) -->
                                <asp:Panel ID="pnlNormalArrival" runat="server" Visible="true">
                                    <div class="time-display my-2"><asp:Literal ID="litArrivalTime" runat="server"></asp:Literal></div>
                                    <div class="time-date"><i class="fa-solid fa-calendar-day me-1"></i> <asp:Literal ID="litArrivalDate" runat="server"></asp:Literal></div>
                                </asp:Panel>

                                <asp:Panel ID="pnlRevisedArrival" runat="server" Visible="false">
                                    <div class="time-original-striked"><asp:Literal ID="litOriginalArrTime" runat="server"></asp:Literal></div>
                                    <div class="time-display time-revised my-1"><i class="fa-solid fa-clock-rotate-left me-1"></i> <asp:Literal ID="litRevisedArrTime" runat="server"></asp:Literal></div>
                                    <div class="time-date text-danger fw-bold"><i class="fa-solid fa-calendar-day me-1"></i> <asp:Literal ID="litRevisedArrDate" runat="server"></asp:Literal> (Updated)</div>
                                </asp:Panel>
                            </div>
                        </div>

                    </div>

                    <!-- Additional Metrics: Available Seats, Aircraft Capacity & Class Fares -->
                    <div class="row g-3 mb-4">
                        <div class="col-md-3 col-sm-6">
                            <div class="info-metric-card">
                                <div class="small text-muted text-uppercase fw-bold"><i class="fa-solid fa-chair text-primary me-1"></i> Available Seats</div>
                                <div class="fs-4 fw-bold text-success"><asp:Literal ID="litAvailableSeats" runat="server"></asp:Literal> <span class="fs-6 fw-normal text-muted">/ <asp:Literal ID="litTotalSeats" runat="server"></asp:Literal></span></div>
                                <small class="text-muted">Live seat inventory</small>
                            </div>
                        </div>

                        <div class="col-md-3 col-sm-6">
                            <div class="info-metric-card">
                                <div class="small text-muted text-uppercase fw-bold"><i class="fa-solid fa-couch text-info me-1"></i> Economy Fare</div>
                                <div class="fs-4 fw-bold text-dark">PKR <asp:Literal ID="litEconomyPrice" runat="server"></asp:Literal></div>
                                <small class="text-muted">Standard seating</small>
                            </div>
                        </div>

                        <div class="col-md-3 col-sm-6">
                            <div class="info-metric-card">
                                <div class="small text-muted text-uppercase fw-bold"><i class="fa-solid fa-briefcase text-warning me-1"></i> Business Fare</div>
                                <div class="fs-4 fw-bold text-dark">PKR <asp:Literal ID="litBusinessPrice" runat="server"></asp:Literal></div>
                                <small class="text-muted">Priority boarding &amp; lounge</small>
                            </div>
                        </div>

                        <div class="col-md-3 col-sm-6">
                            <div class="info-metric-card">
                                <div class="small text-muted text-uppercase fw-bold"><i class="fa-solid fa-crown text-purple me-1"></i> First Class Fare</div>
                                <div class="fs-4 fw-bold text-dark">PKR <asp:Literal ID="litFirstClassPrice" runat="server"></asp:Literal></div>
                                <small class="text-muted">Luxury suite service</small>
                            </div>
                        </div>
                    </div>

                    <!-- Action Bar -->
                    <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 pt-3 border-top">
                        <div class="text-muted small">
                            <i class="fa-solid fa-circle-check text-success me-1"></i> Data queried directly from Central Flight Operations dispatch database.
                        </div>
                        <div class="d-flex gap-2">
                            <asp:Literal ID="litActionButtons" runat="server"></asp:Literal>
                            <a href="TicketStatus.aspx" class="btn btn-outline-secondary"><i class="fa-solid fa-receipt me-1"></i> Check Ticket Status</a>
                        </div>
                    </div>

                </div>
            </div>
        </asp:Panel>
    </div>
</asp:Content>
