<%@ Page Title="View Ticket Status - AeroFly Airline Reservation System" Language="C#" MasterPageFile="~/Shared/Site.Master" AutoEventWireup="true" CodeFile="TicketStatus.aspx.cs" Inherits="User_TicketStatus" EnableEventValidation="false" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .timing-alert-box {
            background: linear-gradient(135deg, #fff3cd 0%, #ffeaa7 100%);
            border-left: 6px solid #fd7e14;
        }
        .time-badge-original {
            text-decoration: line-through;
            color: #6c757d;
        }
        .time-badge-revised {
            font-size: 1.25rem;
            font-weight: 700;
            color: #dc3545;
        }
        .ticket-info-label {
            font-size: 0.85rem;
            text-transform: uppercase;
            font-weight: 600;
            color: #6c757d;
            letter-spacing: 0.5px;
        }
        .ticket-info-value {
            font-size: 1.15rem;
            font-weight: 700;
            color: #212529;
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container py-4">
        <!-- Breadcrumbs -->
        <nav aria-label="breadcrumb" class="mb-3">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="<%= ResolveUrl("~/User/Dashboard.aspx") %>">Home</a></li>
                <li class="breadcrumb-item"><a href="Dashboard.aspx">Dashboard</a></li>
                <li class="breadcrumb-item active" aria-current="page">View Ticket Status</li>
            </ol>
        </nav>

        <div class="ars-card p-4 mb-4 bg-white border-0 shadow-sm border-start border-info border-4">
            <div class="d-flex justify-content-between align-items-center mb-3 flex-wrap gap-2">
                <div>
                    <span class="badge bg-info text-white mb-1"><i class="fa-solid fa-receipt me-1"></i> Phase 11 Module</span>
                    <h2 class="fw-bold mb-0 text-dark"><i class="fa-solid fa-ticket-simple text-primary me-2"></i> View Ticket Status &amp; Flight Timing</h2>
                    <p class="text-muted mb-0">Check live reservation status, passenger details, route itinerary, and real-time flight schedule updates for both Blocked and Confirmed tickets.</p>
                </div>
                <div>
                    <a href="SearchFlights.aspx" class="btn btn-outline-primary"><i class="fa-solid fa-magnifying-glass me-1"></i> Search Flights</a>
                </div>
            </div>

            <!-- Error / Alert Message Banner -->
            <asp:Panel ID="pnlAlert" runat="server" Visible="false" CssClass="alert alert-danger alert-dismissible fade show" role="alert">
                <asp:Literal ID="litAlertMessage" runat="server"></asp:Literal>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </asp:Panel>

            <!-- Search / Retrieve Reference Form -->
            <div class="card p-3 bg-light border mb-4">
                <label class="form-label fw-bold text-dark mb-2">
                    <i class="fa-solid fa-magnifying-glass text-primary me-1"></i> Enter Booking Reference (Blocking Number or Confirmation Number):
                </label>
                <div class="row g-2 align-items-center">
                    <div class="col-md-8">
                        <div class="input-group">
                            <span class="input-group-text bg-white fw-bold text-muted"><i class="fa-solid fa-hashtag"></i></span>
                            <asp:TextBox ID="txtSearchReference" runat="server" CssClass="form-control form-control-lg fw-bold text-uppercase" placeholder="e.g. BLK-90823 or CNF-45872"></asp:TextBox>
                            <asp:Button ID="btnCheckStatus" runat="server" Text="Check Ticket Status" CssClass="btn btn-primary btn-lg px-4 fw-bold" OnClick="btnCheckStatus_Click" />
                        </div>
                    </div>
                    <div class="col-md-4 text-md-end">
                        <asp:Button ID="btnClear" runat="server" Text="Clear" CssClass="btn btn-outline-secondary" OnClick="btnClear_Click" Visible="false" />
                        <a href="Dashboard.aspx" class="btn btn-outline-secondary ms-1"><i class="fa-solid fa-gauge-high me-1"></i> Dashboard</a>
                    </div>
                </div>
                <small class="text-muted mt-2 d-block">
                    <i class="fa-solid fa-circle-info me-1"></i> Supports all booking types: <strong>Blocking Numbers (BLK-XXXXX)</strong>, <strong>Confirmed Tickets (CNF-XXXXX)</strong>, and <strong>Cancellations (CAN-XXXXX)</strong>.
                </small>
            </div>

            <!-- TICKET DETAILS DISPLAY PANEL -->
            <asp:Panel ID="pnlTicketDetails" runat="server" Visible="false">
                
                <!-- LAST-MINUTE FLIGHT TIMING CHANGE HIGHLIGHT BANNER -->
                <asp:Panel ID="pnlTimingChangeAlert" runat="server" Visible="false" CssClass="p-4 mb-4 rounded-3 border timing-alert-box shadow-sm">
                    <div class="d-flex align-items-start">
                        <div class="me-3">
                            <span class="badge bg-danger p-2 fs-5"><i class="fa-solid fa-triangle-exclamation"></i></span>
                        </div>
                        <div class="flex-grow-1">
                            <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 mb-2">
                                <h4 class="fw-bold text-danger mb-0">
                                    <i class="fa-solid fa-clock-rotate-left me-1"></i> LAST-MINUTE FLIGHT TIMING CHANGE DETECTED!
                                </h4>
                                <span class="badge bg-danger fs-6 px-3 py-1 font-monospace">
                                    <asp:Literal ID="litTimingDifference" runat="server"></asp:Literal>
                                </span>
                            </div>
                            <p class="mb-2 text-dark">
                                <strong>Notice to Passenger:</strong> The flight operations control center has issued a schedule timing update for flight <strong><asp:Literal ID="litAlertFlightNumber" runat="server"></asp:Literal></strong>. Please review the updated departure and arrival times below before heading to the airport.
                            </p>
                            <div class="row g-3 bg-white p-3 rounded border mt-1">
                                <div class="col-md-6">
                                    <div class="small text-muted text-uppercase fw-bold">Original Scheduled Departure:</div>
                                    <div class="time-badge-original fs-5"><asp:Literal ID="litOriginalDepSchedule" runat="server"></asp:Literal></div>
                                    <div class="small text-danger text-uppercase fw-bold mt-2">Revised / Updated Departure:</div>
                                    <div class="time-badge-revised"><i class="fa-solid fa-plane-departure me-1"></i> <asp:Literal ID="litRevisedDepSchedule" runat="server"></asp:Literal></div>
                                </div>
                                <div class="col-md-6">
                                    <div class="small text-muted text-uppercase fw-bold">Original Scheduled Arrival:</div>
                                    <div class="time-badge-original fs-5"><asp:Literal ID="litOriginalArrSchedule" runat="server"></asp:Literal></div>
                                    <div class="small text-danger text-uppercase fw-bold mt-2">Revised / Updated Arrival:</div>
                                    <div class="time-badge-revised"><i class="fa-solid fa-plane-arrival me-1"></i> <asp:Literal ID="litRevisedArrSchedule" runat="server"></asp:Literal></div>
                                </div>
                                <div class="col-12 mt-2 pt-2 border-top">
                                    <small class="text-muted"><i class="fa-solid fa-circle-info text-primary me-1"></i> <strong>Reason / Advisory:</strong> <asp:Literal ID="litTimingReason" runat="server"></asp:Literal></small>
                                </div>
                            </div>
                        </div>
                    </div>
                </asp:Panel>

                <!-- ON-TIME TIMING STATUS BANNER (When no timing change) -->
                <asp:Panel ID="pnlOnTimeNotice" runat="server" Visible="false" CssClass="alert alert-success border-success d-flex align-items-center mb-4">
                    <i class="fa-solid fa-circle-check fa-2x text-success me-3"></i>
                    <div>
                        <h6 class="fw-bold mb-0 text-success">Flight Schedule is On-Time</h6>
                        <small class="text-muted">No schedule delays or last-minute timing modifications reported for this flight.</small>
                    </div>
                </asp:Panel>

                <!-- MAIN BOARDING TICKET CARD -->
                <div class="card border-0 shadow-sm mb-4">
                    <!-- Ticket Header -->
                    <div class="card-header bg-dark text-white p-3 d-flex justify-content-between align-items-center flex-wrap gap-2">
                        <div class="d-flex align-items-center">
                            <span class="fs-4 me-3"><i class="fa-solid fa-plane-up text-info"></i></span>
                            <div>
                                <h5 class="fw-bold mb-0 text-white"><asp:Literal ID="litAirlineName" runat="server"></asp:Literal></h5>
                                <small class="text-white-50">Flight No: <strong class="text-white"><asp:Literal ID="litFlightNumber" runat="server"></asp:Literal></strong></small>
                            </div>
                        </div>
                        <div>
                            <span class="ticket-info-label text-white-50 me-2">Reference:</span>
                            <span class="fs-5 fw-bold text-warning font-monospace"><asp:Literal ID="litBookingRef" runat="server"></asp:Literal></span>
                            <span class="ms-2"><asp:Literal ID="litTicketStatusBadge" runat="server"></asp:Literal></span>
                        </div>
                    </div>

                    <!-- Ticket Body -->
                    <div class="card-body p-4 bg-white">
                        <!-- Route & Time Display -->
                        <div class="p-3 bg-light rounded-3 border mb-4">
                            <div class="row align-items-center text-center text-md-start g-3">
                                <!-- Origin -->
                                <div class="col-md-5">
                                    <div class="ticket-info-label">Origin City</div>
                                    <div class="display-6 fw-bold text-dark"><asp:Literal ID="litOriginCity" runat="server"></asp:Literal></div>
                                    <div class="mt-2">
                                        <span class="badge bg-primary me-1"><i class="fa-solid fa-calendar-day me-1"></i> <asp:Literal ID="litDepartureDate" runat="server"></asp:Literal></span>
                                        <span class="badge bg-dark"><i class="fa-solid fa-clock me-1"></i> <asp:Literal ID="litDepartureTime" runat="server"></asp:Literal></span>
                                    </div>
                                </div>

                                <!-- Plane Route Divider -->
                                <div class="col-md-2 text-center my-3 my-md-0">
                                    <div class="text-muted small mb-1"><i class="fa-solid fa-arrow-right-long fa-2x text-primary d-none d-md-inline"></i><i class="fa-solid fa-arrow-down-long fa-2x text-primary d-md-none"></i></div>
                                    <span class="badge bg-secondary-subtle text-secondary border">Direct Flight</span>
                                </div>

                                <!-- Destination -->
                                <div class="col-md-5 text-md-end">
                                    <div class="ticket-info-label">Destination City</div>
                                    <div class="display-6 fw-bold text-dark"><asp:Literal ID="litDestinationCity" runat="server"></asp:Literal></div>
                                    <div class="mt-2">
                                        <span class="badge bg-primary me-1"><i class="fa-solid fa-calendar-day me-1"></i> <asp:Literal ID="litArrivalDate" runat="server"></asp:Literal></span>
                                        <span class="badge bg-dark"><i class="fa-solid fa-clock me-1"></i> <asp:Literal ID="litArrivalTime" runat="server"></asp:Literal></span>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Passenger, Class, Price Breakdown Matrix -->
                        <div class="row g-3 mb-4">
                            <div class="col-sm-6 col-md-3">
                                <div class="p-3 bg-light rounded-3 border h-100">
                                    <div class="ticket-info-label"><i class="fa-solid fa-user text-primary me-1"></i> Passengers</div>
                                    <div class="ticket-info-value"><asp:Literal ID="litPassengerName" runat="server"></asp:Literal></div>
                                    <small class="text-muted">Primary Passenger</small>
                                </div>
                            </div>
                            <div class="col-sm-6 col-md-3">
                                <div class="p-3 bg-light rounded-3 border h-100">
                                    <div class="ticket-info-label"><i class="fa-solid fa-couch text-primary me-1"></i> Travel Class</div>
                                    <div class="ticket-info-value"><asp:Literal ID="litSeatClass" runat="server"></asp:Literal></div>
                                    <small class="text-muted">Reserved Seating</small>
                                </div>
                            </div>
                            <div class="col-sm-6 col-md-3">
                                <div class="p-3 bg-light rounded-3 border h-100">
                                    <div class="ticket-info-label"><i class="fa-solid fa-money-bill-wave text-success me-1"></i> Total Price</div>
                                    <div class="ticket-info-value text-success">PKR <asp:Literal ID="litTotalPrice" runat="server"></asp:Literal></div>
                                    <small class="text-muted">Inclusive of taxes &amp; fees</small>
                                </div>
                            </div>
                            <div class="col-sm-6 col-md-3">
                                <div class="p-3 bg-light rounded-3 border h-100">
                                    <div class="ticket-info-label"><i class="fa-solid fa-calendar-check text-primary me-1"></i> Booking Date</div>
                                    <div class="ticket-info-value fs-6"><asp:Literal ID="litBookingDate" runat="server"></asp:Literal></div>
                                    <small class="text-muted">Reservation Timestamp</small>
                                </div>
                            </div>
                        </div>

                        <!-- Contextual Actions based on Ticket Status -->
                        <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 pt-3 border-top">
                            <div>
                                <span class="text-muted small"><i class="fa-solid fa-user-tag me-1"></i> Account: <strong><asp:Literal ID="litAccountOwner" runat="server"></asp:Literal></strong></span>
                            </div>
                            <div class="d-flex gap-2">
                                <asp:Literal ID="litActionButtons" runat="server"></asp:Literal>
                                <a href="Dashboard.aspx" class="btn btn-outline-secondary"><i class="fa-solid fa-gauge-high me-1"></i> Dashboard</a>
                            </div>
                        </div>
                    </div>
                </div>
            </asp:Panel>
        </div>
    </div>
</asp:Content>


