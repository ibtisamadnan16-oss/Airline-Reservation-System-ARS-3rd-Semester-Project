<%@ Page Title="User Dashboard - Airline Reservation System" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeFile="Dashboard.aspx.cs" Inherits="Dashboard" EnableEventValidation="false" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container py-4">
        <!-- Top Welcome Card -->
        <div class="ars-card p-4 mb-4 bg-white border-0 shadow-sm">
            <div class="row align-items-center gy-3">
                <div class="col-md-8">
                    <div class="d-flex align-items-center">
                        <div class="bg-primary text-white rounded-circle p-3 me-3 d-flex align-items-center justify-content-center" style="width: 60px; height: 60px;">
                            <i class="fa-solid fa-user-check fa-2x"></i>
                        </div>
                        <div>
                            <span class="badge bg-success mb-1">Registered Member Profile</span>
                            <h2 class="fw-bold mb-0">Welcome back, <asp:Literal ID="litFullName" runat="server"></asp:Literal>!</h2>
                            <p class="text-muted mb-0 small">User ID: <asp:Literal ID="litUsername" runat="server"></asp:Literal> &bull; Role: <asp:Literal ID="litRole" runat="server"></asp:Literal></p>
                        </div>
                    </div>
                </div>
                <div class="col-md-4 text-md-end">
                    <div class="p-3 bg-warning-subtle rounded-3 border border-warning d-inline-block text-start">
                        <div class="small text-muted text-uppercase fw-bold">Frequent Flyer Balance</div>
                        <div class="fs-3 fw-bold text-dark">
                            <i class="fa-solid fa-award text-warning me-1"></i>
                            <asp:Literal ID="litSkyMiles" runat="server"></asp:Literal> <span class="fs-6 text-muted">Miles</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Quick Stats Row -->
        <div class="row g-3 mb-4">
            <div class="col-sm-6 col-lg-3">
                <div class="ars-card p-3 h-100">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <div class="small text-muted fw-semibold">Confirmed Tickets</div>
                            <h3 class="fw-bold text-success mb-0 mt-1"><asp:Literal ID="litConfirmedCount" runat="server">0</asp:Literal></h3>
                        </div>
                        <div class="bg-success-subtle text-success p-3 rounded-circle">
                            <i class="fa-solid fa-ticket-simple fa-lg"></i>
                        </div>
                    </div>
                    <small class="text-muted d-block mt-2">Active booked flights</small>
                </div>
            </div>

            <div class="col-sm-6 col-lg-3">
                <div class="ars-card p-3 h-100">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <div class="small text-muted fw-semibold">Blocked Tickets</div>
                            <h3 class="fw-bold text-warning mb-0 mt-1"><asp:Literal ID="litBlockedCount" runat="server">0</asp:Literal></h3>
                        </div>
                        <div class="bg-warning-subtle text-warning p-3 rounded-circle">
                            <i class="fa-solid fa-clock-rotate-left fa-lg"></i>
                        </div>
                    </div>
                    <small class="text-muted d-block mt-2">Temporary seat reservations</small>
                </div>
            </div>

            <div class="col-sm-6 col-lg-3">
                <div class="ars-card p-3 h-100">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <div class="small text-muted fw-semibold">Cancelled Flights</div>
                            <h3 class="fw-bold text-danger mb-0 mt-1"><asp:Literal ID="litCancelledCount" runat="server">0</asp:Literal></h3>
                        </div>
                        <div class="bg-danger-subtle text-danger p-3 rounded-circle">
                            <i class="fa-solid fa-ban fa-lg"></i>
                        </div>
                    </div>
                    <small class="text-muted d-block mt-2">Refunded / Cancelled</small>
                </div>
            </div>

            <div class="col-sm-6 col-lg-3">
                <div class="ars-card p-3 h-100">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <div class="small text-muted fw-semibold">SkyMiles Reward</div>
                            <h3 class="fw-bold text-primary mb-0 mt-1">Tier 1</h3>
                        </div>
                        <div class="bg-primary-subtle text-primary p-3 rounded-circle">
                            <i class="fa-solid fa-star fa-lg"></i>
                        </div>
                    </div>
                    <small class="text-muted d-block mt-2">Silver Member Status</small>
                </div>
            </div>
        </div>

        <!-- Phase 7: Confirm Blocked Ticket Module (Per Requirement) -->
        <div class="ars-card p-4 mb-4 bg-white border-0 shadow-sm border-start border-primary border-4" id="confirm-ticket-module">
            <div class="d-flex justify-content-between align-items-center mb-3 flex-wrap gap-2">
                <div>
                    <span class="badge bg-primary text-white mb-1"><i class="fa-solid fa-ticket me-1"></i> Phase 7 Module</span>
                    <h4 class="fw-bold mb-0 text-dark"><i class="fa-solid fa-circle-check text-success me-2"></i> Confirm Blocked Ticket</h4>
                    <p class="text-muted small mb-0">Enter your Blocking Number (e.g. <code>BLK-17891</code>) to retrieve details, verify the 2-week advance departure rule, and complete payment to confirm your seat.</p>
                </div>
                <div>
                    <span class="badge bg-warning-subtle text-dark border border-warning px-3 py-2">
                        <i class="fa-solid fa-triangle-exclamation text-warning me-1"></i>
                        <strong>Important Rule:</strong> Blocked ticket must be confirmed $\ge$ 2 weeks (14 days) before departure.
                    </span>
                </div>
            </div>

            <!-- Visual Workflow Pipeline -->
            <div class="p-3 bg-light rounded-3 mb-3 border">
                <div class="row text-center g-2 small">
                    <div class="col-6 col-md-3">
                        <div class="p-2 rounded bg-white shadow-sm border">
                            <span class="badge bg-warning text-dark mb-1">Step 1</span>
                            <div class="fw-bold text-dark"><i class="fa-solid fa-lock text-warning me-1"></i> Block Ticket</div>
                            <small class="text-muted">48-Hr Hold Reference</small>
                        </div>
                    </div>
                    <div class="col-6 col-md-3">
                        <div class="p-2 rounded bg-white shadow-sm border">
                            <span class="badge bg-info text-white mb-1">Step 2</span>
                            <div class="fw-bold text-dark"><i class="fa-solid fa-calendar-check text-info me-1"></i> 2-Week Rule Check</div>
                            <small class="text-muted">Departure &ge; 14 Days</small>
                        </div>
                    </div>
                    <div class="col-6 col-md-3">
                        <div class="p-2 rounded bg-white shadow-sm border">
                            <span class="badge bg-primary text-white mb-1">Step 3</span>
                            <div class="fw-bold text-dark"><i class="fa-solid fa-credit-card text-primary me-1"></i> Payment Process</div>
                            <small class="text-muted">Charge Fare Amount</small>
                        </div>
                    </div>
                    <div class="col-6 col-md-3">
                        <div class="p-2 rounded bg-white shadow-sm border">
                            <span class="badge bg-success text-white mb-1">Step 4</span>
                            <div class="fw-bold text-dark"><i class="fa-solid fa-ticket-simple text-success me-1"></i> Confirmed Ticket</div>
                            <small class="text-muted">Issued CNF-XXXXX</small>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Input Form for Blocking Number -->
            <div class="row g-2 align-items-center mb-3">
                <div class="col-md-8">
                    <div class="input-group">
                        <span class="input-group-text bg-light fw-bold text-muted"><i class="fa-solid fa-hashtag"></i></span>
                        <asp:TextBox ID="txtBlockingNumber" runat="server" CssClass="form-control form-control-lg fw-bold text-primary" placeholder="Enter Blocking Number (e.g. BLK-17891)"></asp:TextBox>
                        <asp:Button ID="btnRetrieveBlock" runat="server" Text="Retrieve Ticket Details" CssClass="btn btn-primary btn-lg px-4" OnClick="btnRetrieveBlock_Click" />
                    </div>
                </div>
                <div class="col-md-4 text-md-end">
                    <asp:Button ID="btnResetBlockSearch" runat="server" Text="Reset Form" CssClass="btn btn-outline-secondary" OnClick="btnResetBlockSearch_Click" Visible="false" />
                </div>
            </div>

            <!-- Status Alert Message -->
            <asp:Panel ID="pnlBlockMessage" runat="server" Visible="false" CssClass="alert alert-dismissible mb-3">
                <asp:Literal ID="litBlockMessage" runat="server"></asp:Literal>
            </asp:Panel>

            <!-- Block Details Panel (When Ticket Found) -->
            <asp:Panel ID="pnlBlockDetails" runat="server" Visible="false" CssClass="ars-card border border-primary p-3 bg-light mb-3">
                <div class="d-flex justify-content-between align-items-center mb-3 pb-2 border-bottom flex-wrap gap-2">
                    <div>
                        <span class="badge bg-warning text-dark me-2 fs-6">
                            <i class="fa-solid fa-lock me-1"></i> Reference: <asp:Literal ID="litDetailsRef" runat="server"></asp:Literal>
                        </span>
                        <span class="badge bg-secondary"><asp:Literal ID="litDetailsStatus" runat="server"></asp:Literal></span>
                    </div>
                    <div class="text-end">
                        <span class="text-muted small">Passenger Name:</span> <strong><asp:Literal ID="litDetailsPassenger" runat="server"></asp:Literal></strong>
                    </div>
                </div>

                <div class="row g-3">
                    <div class="col-md-7">
                        <div class="bg-white p-3 rounded border">
                            <div class="d-flex justify-content-between align-items-center mb-2">
                                <span class="fw-bold fs-5 text-dark"><asp:Literal ID="litDetailsFlight" runat="server"></asp:Literal></span>
                                <span class="badge bg-primary"><asp:Literal ID="litDetailsClass" runat="server"></asp:Literal> Class</span>
                            </div>
                            <div class="row text-muted small mb-3">
                                <div class="col-6">
                                    <span class="d-block fw-semibold text-dark"><i class="fa-solid fa-plane-departure text-primary me-1"></i> <asp:Literal ID="litDetailsOrigin" runat="server"></asp:Literal></span>
                                    <span>Departure: <strong class="text-dark"><asp:Literal ID="litDetailsDepTime" runat="server"></asp:Literal></strong></span>
                                </div>
                                <div class="col-6 text-end">
                                    <span class="d-block fw-semibold text-dark"><i class="fa-solid fa-plane-arrival text-primary me-1"></i> <asp:Literal ID="litDetailsDest" runat="server"></asp:Literal></span>
                                    <span>Arrival: <strong class="text-dark"><asp:Literal ID="litDetailsArrTime" runat="server"></asp:Literal></strong></span>
                                </div>
                            </div>
                            <div class="p-2 rounded bg-light border small">
                                <strong>2-Week Rule Compliance Check:</strong>
                                <div class="mt-1">
                                    <asp:Literal ID="litDetailsDaysNotice" runat="server"></asp:Literal>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-md-5">
                        <div class="bg-white p-3 rounded border h-100 d-flex flex-column justify-content-between">
                            <div>
                                <div class="d-flex justify-content-between align-items-center mb-2">
                                    <span class="text-muted">Total Fare Payable:</span>
                                    <span class="fs-4 fw-bold text-success">PKR <asp:Literal ID="litDetailsPrice" runat="server"></asp:Literal></span>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label small fw-semibold text-muted mb-1">Settlement Credit Card:</label>
                                    <div class="input-group input-group-sm">
                                        <span class="input-group-text"><i class="fa-solid fa-credit-card text-muted"></i></span>
                                        <asp:TextBox ID="txtPaymentCardNumber" runat="server" CssClass="form-control fw-bold" placeholder="Card Number (XXXX-XXXX-XXXX-XXXX)"></asp:TextBox>
                                    </div>
                                    <small class="text-muted">Auto-loaded from user profile card preferences</small>
                                </div>
                            </div>

                            <div>
                                <asp:HiddenField ID="hfReservationId" runat="server" />
                                <asp:HiddenField ID="hfFlightId" runat="server" />
                                <asp:HiddenField ID="hfUserId" runat="server" />
                                
                                <asp:Button ID="btnConfirmPayment" runat="server" Text="Pay &amp; Confirm Ticket" CssClass="btn btn-success w-100 fw-bold py-2 mb-2" OnClick="btnConfirmPayment_Click" />
                                
                                <asp:Button ID="btnCancelExpired" runat="server" Text="Cancel Expired Hold &amp; Release Seat" CssClass="btn btn-outline-danger btn-sm w-100" OnClick="btnCancelExpired_Click" Visible="false" />
                            </div>
                        </div>
                    </div>
                </div>
            </asp:Panel>

            <!-- Confirmation Success Panel -->
            <asp:Panel ID="pnlConfirmationSuccess" runat="server" Visible="false" CssClass="alert alert-success border-success p-4 mb-3">
                <div class="d-flex align-items-center mb-3">
                    <div class="bg-success text-white p-3 rounded-circle me-3">
                        <i class="fa-solid fa-circle-check fa-2x"></i>
                    </div>
                    <div>
                        <h4 class="alert-heading fw-bold mb-1">Ticket Confirmed Successfully!</h4>
                        <p class="mb-0 text-muted">Your blocked reservation has been paid and confirmed. Your official confirmation number has been generated.</p>
                    </div>
                </div>
                <div class="row g-3 bg-white p-3 rounded border text-dark mb-3">
                    <div class="col-sm-6 col-md-3">
                        <small class="text-muted d-block">Original Blocking Number</small>
                        <code class="fs-6 text-muted"><asp:Literal ID="litSuccessOldRef" runat="server"></asp:Literal></code>
                    </div>
                    <div class="col-sm-6 col-md-3">
                        <small class="text-muted d-block text-success fw-bold">Official Confirmation Number</small>
                        <span class="fs-5 fw-bold text-success"><asp:Literal ID="litSuccessNewRef" runat="server"></asp:Literal></span>
                    </div>
                    <div class="col-sm-6 col-md-3">
                        <small class="text-muted d-block">Status</small>
                        <span class="badge bg-success">Confirmed &amp; Paid</span>
                    </div>
                    <div class="col-sm-6 col-md-3">
                        <small class="text-muted d-block">SkyMiles Awarded</small>
                        <span class="badge bg-warning text-dark"><i class="fa-solid fa-award me-1"></i> +350 Miles Added</span>
                    </div>
                </div>
                <div class="small text-muted mb-0">
                    <strong>Executed Pipeline:</strong>
                    <code>Block (<asp:Literal ID="litSuccessPipelineOld" runat="server"></asp:Literal>)</code> &rarr; 
                    <code>Payment Charge Processed</code> &rarr; 
                    <code>Confirmed Ticket</code> &rarr; 
                    <code>Confirmation Number Issued (<asp:Literal ID="litSuccessPipelineCnf" runat="server"></asp:Literal>)</code>
                </div>
            </asp:Panel>
        </div>

        <!-- Quick Ticket Operations Bar -->
        <div class="row g-3 mb-4">
            <div class="col-sm-6 col-lg-3">
                <a href="ConfirmBlockedTicket.aspx" class="card text-decoration-none border-primary h-100 shadow-sm p-3 hover-shadow">
                    <div class="d-flex align-items-center">
                        <div class="bg-primary text-white p-3 rounded-circle me-3">
                            <i class="fa-solid fa-circle-check fa-lg"></i>
                        </div>
                        <div>
                            <span class="badge bg-primary mb-1">Phase 7</span>
                            <h6 class="fw-bold text-dark mb-0">Confirm Blocked Ticket</h6>
                            <small class="text-muted">Pay &amp; issue confirmation</small>
                        </div>
                    </div>
                </a>
            </div>
            <div class="col-sm-6 col-lg-3">
                <a href="RescheduleTicket.aspx" class="card text-decoration-none border-info h-100 shadow-sm p-3 hover-shadow">
                    <div class="d-flex align-items-center">
                        <div class="bg-info text-white p-3 rounded-circle me-3">
                            <i class="fa-solid fa-arrows-rotate fa-lg"></i>
                        </div>
                        <div>
                            <span class="badge bg-info mb-1">Phase 8</span>
                            <h6 class="fw-bold text-dark mb-0">Reschedule Ticket</h6>
                            <small class="text-muted">Change dates &amp; fare difference</small>
                        </div>
                    </div>
                </a>
            </div>
            <div class="col-sm-6 col-lg-3">
                <a href="CancelTicket.aspx" class="card text-decoration-none border-danger h-100 shadow-sm p-3 hover-shadow">
                    <div class="d-flex align-items-center">
                        <div class="bg-danger text-white p-3 rounded-circle me-3">
                            <i class="fa-solid fa-rectangle-xmark fa-lg"></i>
                        </div>
                        <div>
                            <span class="badge bg-danger mb-1">Phase 9</span>
                            <h6 class="fw-bold text-dark mb-0">Cancel Ticket &amp; Refund</h6>
                            <small class="text-muted">Policy refund &amp; seat restore</small>
                        </div>
                    </div>
                </a>
            </div>
            <div class="col-sm-6 col-lg-3">
                <a href="Profile.aspx" class="card text-decoration-none border-success h-100 shadow-sm p-3 hover-shadow">
                    <div class="d-flex align-items-center">
                        <div class="bg-success text-white p-3 rounded-circle me-3">
                            <i class="fa-solid fa-user-gear fa-lg"></i>
                        </div>
                        <div>
                            <span class="badge bg-success mb-1">Phase 10</span>
                            <h6 class="fw-bold text-dark mb-0">My Profile Management</h6>
                            <small class="text-muted">Update address, phone &amp; card</small>
                        </div>
                    </div>
                </a>
            </div>
        </div>

        <div class="row g-4">
            <!-- User Profile Details Card (Section 3.2 Specification) -->
            <div class="col-lg-5">
                <div class="ars-card h-100">
                    <div class="card-header-custom d-flex justify-content-between align-items-center">
                        <span><i class="fa-solid fa-id-card me-2"></i> Passenger Profile</span>
                        <span class="badge bg-light text-dark">Verified</span>
                    </div>
                    <div class="p-4">
                        <table class="table table-sm table-borderless mb-3">
                            <tr>
                                <td class="text-muted fw-semibold" style="width: 40%;"><i class="fa-solid fa-user me-1 text-primary"></i> Full Name:</td>
                                <td class="fw-bold"><asp:Literal ID="litTblName" runat="server"></asp:Literal></td>
                            </tr>
                            <tr>
                                <td class="text-muted fw-semibold"><i class="fa-solid fa-envelope me-1 text-primary"></i> Email:</td>
                                <td><asp:Literal ID="litTblEmail" runat="server"></asp:Literal></td>
                            </tr>
                            <tr>
                                <td class="text-muted fw-semibold"><i class="fa-solid fa-phone me-1 text-primary"></i> Phone:</td>
                                <td><asp:Literal ID="litTblPhone" runat="server"></asp:Literal></td>
                            </tr>
                            <tr>
                                <td class="text-muted fw-semibold"><i class="fa-solid fa-venus-mars me-1 text-primary"></i> Gender &bull; Age:</td>
                                <td><asp:Literal ID="litTblGenderAge" runat="server"></asp:Literal></td>
                            </tr>
                            <tr>
                                <td class="text-muted fw-semibold"><i class="fa-solid fa-location-dot me-1 text-primary"></i> Address:</td>
                                <td><asp:Literal ID="litTblAddress" runat="server"></asp:Literal></td>
                            </tr>
                            <tr>
                                <td class="text-muted fw-semibold"><i class="fa-solid fa-credit-card me-1 text-primary"></i> Preferred Card:</td>
                                <td><code><asp:Literal ID="litTblCard" runat="server"></asp:Literal></code></td>
                            </tr>
                            <tr>
                                <td class="text-muted fw-semibold"><i class="fa-solid fa-award me-1 text-primary"></i> Sky Miles:</td>
                                <td><span class="badge bg-warning text-dark fw-bold"><asp:Literal ID="litTblMiles" runat="server"></asp:Literal></span></td>
                            </tr>
                        </table>

                        <hr />
                        <div class="d-flex gap-2 flex-wrap">
                            <a href="Profile.aspx" class="btn btn-primary-custom flex-grow-1">
                                <i class="fa-solid fa-id-card me-1"></i> My Profile
                            </a>
                            <a href="Profile.aspx?mode=edit" class="btn btn-outline-primary flex-grow-1">
                                <i class="fa-solid fa-user-pen me-1"></i> Edit Profile
                            </a>
                        </div>
                        <div class="d-flex gap-2 mt-2">
                            <a href="Default.aspx#search-flights" class="btn btn-outline-success flex-grow-1">
                                <i class="fa-solid fa-magnifying-glass me-1"></i> Book New Flight
                            </a>
                            <a href="Logout.aspx" class="btn btn-outline-danger">
                                <i class="fa-solid fa-right-from-bracket me-1"></i> Logout
                            </a>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Recent Bookings and Transaction Options -->
            <div class="col-lg-7">
                <div class="ars-card h-100">
                    <div class="card-header-custom d-flex justify-content-between align-items-center">
                        <span><i class="fa-solid fa-plane-circle-check me-2"></i> My Flight Reservations</span>
                        <span class="badge bg-light text-dark">Live Bookings</span>
                    </div>
                    <div class="p-4">
                        <asp:Panel ID="pnlNoReservations" runat="server" Visible="false" CssClass="text-center py-5">
                            <i class="fa-solid fa-ticket-simple fa-3x text-muted mb-3"></i>
                            <h5 class="fw-bold">No Reservations Yet</h5>
                            <p class="text-muted">You have not blocked or purchased any flight tickets yet.</p>
                            <a href="Default.aspx#search-flights" class="btn btn-primary-custom">
                                <i class="fa-solid fa-magnifying-glass me-1"></i> Check Available Flights
                            </a>
                        </asp:Panel>

                        <asp:Repeater ID="rptReservations" runat="server">
                            <HeaderTemplate>
                                <div class="table-responsive">
                                    <table class="table table-hover align-middle border">
                                        <thead class="table-light">
                                            <tr>
                                                <th>Ref #</th>
                                                <th>Flight</th>
                                                <th>Route</th>
                                                <th>Class</th>
                                                <th>Status</th>
                                                <th>Actions</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                            </HeaderTemplate>
                            <ItemTemplate>
                                <tr>
                                    <td class="fw-bold text-primary"><%# Eval("BookingReference") %></td>
                                    <td><%# Eval("FlightNumber") %></td>
                                    <td>
                                        <small><%# Eval("OriginCity") %> &rarr; <%# Eval("DestinationCity") %></small>
                                    </td>
                                    <td><%# Eval("SeatClass") %></td>
                                    <td>
                                        <span class="badge <%# Eval("Status").ToString() == "Confirmed" ? "bg-success" : (Eval("Status").ToString() == "Blocked" ? "bg-warning text-dark" : "bg-danger") %>">
                                            <%# Eval("Status") %>
                                        </span>
                                    </td>
                                    <td>
                                        <%# RenderActionButtons(Eval("Status"), Eval("BookingReference")) %>
                                    </td>
                                </tr>
                            </ItemTemplate>
                            <FooterTemplate>
                                        </tbody>
                                    </table>
                                </div>
                            </FooterTemplate>
                        </asp:Repeater>

                        <div class="alert alert-secondary mt-3 small mb-0">
                            <i class="fa-solid fa-circle-info me-1"></i>
                            <strong>Phase 1 Note:</strong> As a registered user, you are entitled to perform ticket blocking, booking, rescheduling, and cancellation (Section 1.1). Real-time booking transactions will be active in subsequent phases.
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
