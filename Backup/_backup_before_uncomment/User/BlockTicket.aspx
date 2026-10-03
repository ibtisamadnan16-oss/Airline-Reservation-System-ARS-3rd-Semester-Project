<%@ Page Title="Ticket Pricing & Reservation - Airline Reservation System" Language="C#" MasterPageFile="~/Shared/Site.Master" AutoEventWireup="true" CodeFile="BlockTicket.aspx.cs" Inherits="User_BlockTicket" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .pricing-table th {
            background-color: #f1f5f9;
        }
        .policy-badge-90 {
            background-color: #dcfce7;
            color: #15803d;
            font-weight: 700;
        }
        .policy-badge-70 {
            background-color: #fef9c3;
            color: #a16207;
            font-weight: 700;
        }
        .policy-badge-40 {
            background-color: #ffedd5;
            color: #c2410c;
            font-weight: 700;
        }
        .policy-badge-0 {
            background-color: #fee2e2;
            color: #b91c1c;
            font-weight: 700;
        }
        .ticket-receipt-card {
            border: 2px dashed #0284c7;
            background: #f8fafc;
            border-radius: 12px;
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container py-4">
        <!-- Breadcrumb -->
        <nav aria-label="breadcrumb" class="mb-3">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="<%= ResolveUrl("~/User/Dashboard.aspx") %>">Home</a></li>
                <li class="breadcrumb-item"><a href="<%= ResolveUrl("~/User/SearchFlights.aspx") %>">Search</a></li>
                <li class="breadcrumb-item"><a href="javascript:history.back()">Flight Results</a></li>
                <li class="breadcrumb-item active" aria-current="page">Ticket Pricing &amp; Reservation</li>
            </ol>
        </nav>

        <!-- System Alerts -->
        <asp:Panel ID="pnlAlert" runat="server" Visible="false" CssClass="alert alert-danger mb-4">
            <i class="fa-solid fa-circle-exclamation me-2"></i>
            <asp:Literal ID="litAlertMsg" runat="server"></asp:Literal>
        </asp:Panel>

        <!-- SUCCESS CONFIRMATION RECEIPT (Shown after Booking or Blocking) -->
        <asp:Panel ID="pnlBookingSuccess" runat="server" Visible="false" CssClass="ars-card p-4 p-md-5 mb-5 bg-white border-0 shadow">
            <div class="text-center mb-4">
                <div class="bg-success text-white rounded-circle d-inline-flex align-items-center justify-content-center p-3 mb-3" style="width: 75px; height: 75px;">
                    <i class="fa-solid fa-check fa-3x"></i>
                </div>
                <h2 class="fw-bold text-success mb-1">
                    <asp:Literal ID="litSuccessHeading" runat="server">Reservation Successful!</asp:Literal>
                </h2>
                <p class="text-muted">Your flight booking reference (PNR) has been generated and recorded in the database.</p>
            </div>

            <div class="ticket-receipt-card p-4 mx-auto mb-4" style="max-width: 750px;">
                <div class="d-flex justify-content-between align-items-center border-bottom pb-3 mb-3">
                    <div>
                        <span class="text-muted small text-uppercase fw-bold"><asp:Literal ID="litSuccessRefLabel" runat="server">Confirmation Number (CNF)</asp:Literal></span>
                        <div class="fs-2 fw-bold text-primary font-monospace"><asp:Literal ID="litSuccessPNR" runat="server"></asp:Literal></div>
                    </div>
                    <div class="text-end">
                        <span class="text-muted small text-uppercase fw-bold">Reservation Status</span>
                        <div><asp:Literal ID="litSuccessStatusBadge" runat="server"></asp:Literal></div>
                    </div>
                </div>

                <!-- Transaction Flow Completed Summary -->
                <div class="p-2 mb-3 bg-light rounded text-center small border">
                    <asp:Literal ID="litWorkflowSteps" runat="server"></asp:Literal>
                </div>

                <div class="row g-3 mb-3">
                    <div class="col-sm-6">
                        <small class="text-muted d-block">Passenger Name</small>
                        <strong class="fs-6"><asp:Literal ID="litSuccessPassenger" runat="server"></asp:Literal></strong>
                    </div>
                    <div class="col-sm-6">
                        <small class="text-muted d-block">Flight &amp; Airline</small>
                        <strong class="fs-6"><asp:Literal ID="litSuccessFlight" runat="server"></asp:Literal></strong>
                    </div>
                    <div class="col-sm-6">
                        <small class="text-muted d-block">Route &amp; Class</small>
                        <strong><asp:Literal ID="litSuccessRouteClass" runat="server"></asp:Literal></strong>
                    </div>
                    <div class="col-sm-6">
                        <small class="text-muted d-block">Total Paid / Payable</small>
                        <strong class="fs-5 text-success">PKR <asp:Literal ID="litSuccessTotal" runat="server"></asp:Literal></strong>
                    </div>
                </div>

                <div class="bg-light p-3 rounded small text-muted border">
                    <i class="fa-solid fa-circle-info text-primary me-1"></i>
                    <strong>Cancellation Rule Reminder:</strong> If you cancel 30+ days prior, a 90% refund applies; 15-30 days gives 70%; less than 15 days gives 40% refund.
                </div>
            </div>

            <div class="text-center">
                <a href="Dashboard.aspx" class="btn btn-primary-custom px-4 py-2 me-2">
                    <i class="fa-solid fa-gauge-high me-1"></i> View in Dashboard
                </a>
                <a href="<%= ResolveUrl("~/User/Dashboard.aspx") %>" class="btn btn-outline-secondary px-4 py-2">
                    <i class="fa-solid fa-house me-1"></i> Return to Home
                </a>
            </div>
        </asp:Panel>

        <!-- MAIN RESERVATION FORM (Shown prior to confirmation) -->
        <asp:Panel ID="pnlReservationForm" runat="server">
            <div class="row g-4">
                <!-- LEFT COLUMN: FLIGHT REVIEW & PASSENGER INPUT -->
                <div class="col-lg-7">
                    <!-- Selected Flight Details Card -->
                    <div class="ars-card mb-4">
                        <div class="card-header-custom d-flex justify-content-between align-items-center">
                            <span class="fs-5"><i class="fa-solid fa-plane-departure me-2"></i> Selected Flight Details</span>
                            <span class="badge bg-light text-dark"><asp:Literal ID="litHeaderTripType" runat="server"></asp:Literal></span>
                        </div>

                        <div class="p-4">
                            <!-- Onward Flight Block -->
                            <div class="p-3 bg-light rounded-3 border mb-3">
                                <div class="d-flex justify-content-between align-items-center mb-2">
                                    <span class="badge bg-primary px-3 py-1">Onward Flight</span>
                                    <span class="fw-bold text-primary fs-6"><asp:Literal ID="litOnwardFlightNumber" runat="server"></asp:Literal></span>
                                </div>
                                <div class="row align-items-center text-center text-sm-start gy-2">
                                    <div class="col-sm-5">
                                        <div class="fs-5 fw-bold text-dark"><asp:Literal ID="litOnwardDepTime" runat="server"></asp:Literal></div>
                                        <div class="small fw-semibold text-primary"><asp:Literal ID="litOnwardOrigin" runat="server"></asp:Literal></div>
                                        <div class="small text-muted"><asp:Literal ID="litOnwardDepDate" runat="server"></asp:Literal></div>
                                    </div>
                                    <div class="col-sm-2 text-center">
                                        <small class="text-muted d-block"><asp:Literal ID="litOnwardDuration" runat="server"></asp:Literal></small>
                                        <i class="fa-solid fa-arrow-right text-muted"></i>
                                    </div>
                                    <div class="col-sm-5 text-sm-end">
                                        <div class="fs-5 fw-bold text-dark"><asp:Literal ID="litOnwardArrTime" runat="server"></asp:Literal></div>
                                        <div class="small fw-semibold text-danger"><asp:Literal ID="litOnwardDest" runat="server"></asp:Literal></div>
                                        <div class="small text-muted"><asp:Literal ID="litOnwardArrDate" runat="server"></asp:Literal></div>
                                    </div>
                                </div>
                                <hr class="my-2" />
                                <div class="d-flex justify-content-between small text-muted">
                                    <span>Airline: <strong class="text-dark"><asp:Literal ID="litOnwardAirline" runat="server"></asp:Literal></strong></span>
                                    <span>Class: <strong class="text-dark"><asp:Literal ID="litTravelClass" runat="server"></asp:Literal></strong></span>
                                </div>
                            </div>

                            <!-- Return Flight Block (If Round-Trip) -->
                            <asp:PlaceHolder ID="phReturnFlightCard" runat="server" Visible="false">
                                <div class="p-3 bg-light rounded-3 border mb-3">
                                    <div class="d-flex justify-content-between align-items-center mb-2">
                                        <span class="badge bg-dark px-3 py-1">Return Flight</span>
                                        <span class="fw-bold text-primary fs-6"><asp:Literal ID="litReturnFlightNumber" runat="server"></asp:Literal></span>
                                    </div>
                                    <div class="row align-items-center text-center text-sm-start gy-2">
                                        <div class="col-sm-5">
                                            <div class="fs-5 fw-bold text-dark"><asp:Literal ID="litReturnDepTime" runat="server"></asp:Literal></div>
                                            <div class="small fw-semibold text-primary"><asp:Literal ID="litReturnOrigin" runat="server"></asp:Literal></div>
                                            <div class="small text-muted"><asp:Literal ID="litReturnDepDate" runat="server"></asp:Literal></div>
                                        </div>
                                        <div class="col-sm-2 text-center">
                                            <small class="text-muted d-block"><asp:Literal ID="litReturnDuration" runat="server"></asp:Literal></small>
                                            <i class="fa-solid fa-arrow-right text-muted"></i>
                                        </div>
                                        <div class="col-sm-5 text-sm-end">
                                            <div class="fs-5 fw-bold text-dark"><asp:Literal ID="litReturnArrTime" runat="server"></asp:Literal></div>
                                            <div class="small fw-semibold text-danger"><asp:Literal ID="litReturnDest" runat="server"></asp:Literal></div>
                                            <div class="small text-muted"><asp:Literal ID="litReturnArrDate" runat="server"></asp:Literal></div>
                                        </div>
                                    </div>
                                    <hr class="my-2" />
                                    <div class="d-flex justify-content-between small text-muted">
                                        <span>Airline: <strong class="text-dark"><asp:Literal ID="litReturnAirline" runat="server"></asp:Literal></strong></span>
                                        <span>Available Seats: <strong class="text-success"><asp:Literal ID="litReturnSeats" runat="server"></asp:Literal></strong></span>
                                    </div>
                                </div>
                            </asp:PlaceHolder>
                        </div>
                    </div>

                    <!-- Passenger Details Input Form -->
                    <div class="ars-card mb-4">
                        <div class="card-header-custom">
                            <span class="fs-5"><i class="fa-solid fa-user-pen me-2"></i> Lead Passenger &amp; Contact Details</span>
                        </div>
                        <div class="p-4">
                            <div class="row g-3">
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Passenger Full Name <span class="text-danger">*</span></label>
                                    <asp:TextBox ID="txtPassengerName" runat="server" CssClass="form-control" placeholder="e.g. John Doe" />
                                    <asp:RequiredFieldValidator ID="rfvPassengerName" runat="server" ControlToValidate="txtPassengerName"
                                        ErrorMessage="Passenger name is required." CssClass="text-danger small" Display="Dynamic" />
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">CNIC / Passport Number <span class="text-danger">*</span></label>
                                    <asp:TextBox ID="txtCNIC" runat="server" CssClass="form-control" placeholder="e.g. 42101-1234567-1" />
                                    <asp:RequiredFieldValidator ID="rfvCNIC" runat="server" ControlToValidate="txtCNIC"
                                        ErrorMessage="CNIC or Passport is required." CssClass="text-danger small" Display="Dynamic" />
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Contact Phone <span class="text-danger">*</span></label>
                                    <asp:TextBox ID="txtPhone" runat="server" CssClass="form-control" placeholder="+92 300 1234567" />
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Contact Email <span class="text-danger">*</span></label>
                                    <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" TextMode="Email" placeholder="passenger@example.com" />
                                </div>

                                <div class="col-12">
                                    <label class="form-label fw-semibold">Preferred Credit Card Number</label>
                                    <asp:TextBox ID="txtCreditCard" runat="server" CssClass="form-control" placeholder="16-digit Card Number" />
                                    <small class="text-muted">Pre-filled from your registered profile.</small>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- RIGHT COLUMN: TICKET PRICING BREAKDOWN & CANCELLATION POLICY -->
                <div class="col-lg-5">
                    <!-- Dynamic Ticket Pricing Breakdown Card -->
                    <div class="ars-card mb-4">
                        <div class="card-header-custom d-flex justify-content-between align-items-center">
                            <span class="fs-5"><i class="fa-solid fa-receipt me-2"></i> Ticket Price Calculation</span>
                            <span class="badge bg-warning text-dark"><asp:Literal ID="litTotalPassengerCount" runat="server">1</asp:Literal> Passenger(s)</span>
                        </div>

                        <div class="p-4">
                            <table class="table table-sm table-borderless mb-0">
                                <tr>
                                    <td>Base Fare (Per Adult):</td>
                                    <td class="text-end fw-semibold">PKR <asp:Literal ID="litBaseFarePerAdult" runat="server"></asp:Literal></td>
                                </tr>
                                <tr>
                                    <td><asp:Literal ID="litAdultLabel" runat="server">Adults (1x):</asp:Literal></td>
                                    <td class="text-end fw-semibold">PKR <asp:Literal ID="litAdultSubtotal" runat="server"></asp:Literal></td>
                                </tr>
                                <asp:PlaceHolder ID="phChildFare" runat="server" Visible="false">
                                    <tr>
                                        <td><asp:Literal ID="litChildLabel" runat="server">Children (25% Concession):</asp:Literal></td>
                                        <td class="text-end fw-semibold text-success">- PKR <asp:Literal ID="litChildSubtotal" runat="server"></asp:Literal></td>
                                    </tr>
                                </asp:PlaceHolder>
                                <asp:PlaceHolder ID="phSeniorFare" runat="server" Visible="false">
                                    <tr>
                                        <td><asp:Literal ID="litSeniorLabel" runat="server">Senior Citizens (15% Concession):</asp:Literal></td>
                                        <td class="text-end fw-semibold text-success">- PKR <asp:Literal ID="litSeniorSubtotal" runat="server"></asp:Literal></td>
                                    </tr>
                                </asp:PlaceHolder>
                                <tr>
                                    <td>Airport Security &amp; Fuel Surcharge (5%):</td>
                                    <td class="text-end fw-semibold text-muted">PKR <asp:Literal ID="litTaxes" runat="server"></asp:Literal></td>
                                </tr>
                                <tr class="border-top pt-2">
                                    <td class="fs-5 fw-bold text-dark pt-3">Total Payable Price:</td>
                                    <td class="fs-4 fw-bold text-success text-end pt-3">PKR <asp:Literal ID="litGrandTotal" runat="server"></asp:Literal></td>
                                </tr>
                            </table>

                            <div class="small text-muted mt-2">
                                 <i class="fa-solid fa-award text-warning me-1"></i>
                                 Confirmed ticket booking earns <strong>+350 SkyMiles</strong> in your AeroFly account.
                            </div>

                            <hr class="my-4" />

                            <!-- Phase 6: Buy Ticket vs Block Ticket Choice & 14-Day Rule -->
                            <% if (AirlineReservationSystem.UserStateHelper.IsLoggedIn) { %>
                                <div class="mb-3 text-center">
                                    <h6 class="fw-bold text-dark mb-1">
                                        <i class="fa-solid fa-list-check text-primary me-1"></i> Do you want to:
                                    </h6>
                                    <div class="d-flex justify-content-center gap-2 small fw-bold text-muted mb-2">
                                        <span class="badge bg-secondary-subtle text-dark border">[ Block Ticket ]</span>
                                        <span>or</span>
                                        <span class="badge bg-secondary-subtle text-dark border">[ Buy Ticket ]</span>
                                    </div>

                                    <!-- Rule 1 / Rule 2 Evaluation Alert Box -->
                                    <asp:Panel ID="pnlBlockingRuleNotice" runat="server" CssClass="alert p-2 small mb-3 text-start">
                                        <asp:Literal ID="litBlockingRuleNotice" runat="server"></asp:Literal>
                                    </asp:Panel>
                                </div>

                                <div class="d-grid gap-2">
                                    <!-- Buy Ticket Button (Always Available) -->
                                    <asp:Button ID="btnBuyTicket" runat="server" Text="[ Buy Ticket ]" 
                                        CssClass="btn btn-success py-2 fs-5 fw-bold" OnClick="btnBuyTicket_Click" />

                                    <!-- Block Ticket Button (Conditionally Enabled based on > 14 days rule) -->
                                    <asp:Button ID="btnBlockTicket" runat="server" Text="[ Block Ticket ]" 
                                        CssClass="btn btn-warning text-dark py-2 fw-bold" OnClick="btnBlockTicket_Click" />
                                </div>
                                <div class="text-center mt-2">
                                    <small class="text-muted"><i class="fa-solid fa-shield-halved me-1"></i>Secure 256-bit encrypted transaction</small>
                                </div>
                            <% } else { %>
                                <div class="alert alert-warning p-3 small mb-3">
                                    <i class="fa-solid fa-lock me-1"></i>
                                    <strong>Guest Mode:</strong> Per Section 3.1.1.2, guests can verify pricing &amp; cancellation rules, but must log in to finalize transactions.
                                </div>
                                <a href="<%= ResolveUrl("~/Public/Login.aspx?msg=auth_required") %>" class="btn btn-warning w-100 py-2 text-dark fw-bold mb-2">
                                    <i class="fa-solid fa-right-to-bracket me-1"></i> Sign In to Reserve or Block
                                </a>
                                <a href="Register.aspx" class="btn btn-outline-secondary w-100 py-2">
                                    <i class="fa-solid fa-user-plus me-1"></i> Register New Profile
                                </a>
                            <% } %>
                        </div>
                    </div>

                    <!-- APPLICABLE CANCELLATION POLICY & REFUND TABLE (Section 3.6 / Phase 5) -->
                    <div class="ars-card">
                        <div class="card-header-custom d-flex justify-content-between align-items-center">
                            <span class="fs-5"><i class="fa-solid fa-shield-halved me-2"></i> Cancellation &amp; Refund Policy</span>
                            <span class="badge bg-light text-dark">Section 3.6 Rules</span>
                        </div>
                        <div class="p-4">
                            <p class="small text-muted mb-3">
                                Applicable refund percentages and deduction penalties based on the cancellation time window:
                            </p>

                            <div class="table-responsive">
                                <table class="table table-bordered table-sm align-middle text-center mb-3">
                                    <thead class="table-light">
                                        <tr class="small text-uppercase">
                                            <th>Cancellation Period</th>
                                            <th>Refund %</th>
                                            <th>Penalty</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <asp:Repeater ID="rptCancellationPolicies" runat="server">
                                            <ItemTemplate>
                                                <tr>
                                                    <td class="text-start fw-semibold small">
                                                        <i class="fa-regular fa-clock text-primary me-1"></i>
                                                        <%# Eval("PeriodDescription") %>
                                                    </td>
                                                    <td>
                                                        <span class='badge <%# GetRefundBadgeClass(Eval("RefundPercentage")) %>'>
                                                            <%# Eval("RefundPercentage") %>%
                                                        </span>
                                                    </td>
                                                    <td class="small text-danger fw-semibold">
                                                        <%# Eval("DeductionPercentage") %>% deduction
                                                    </td>
                                                </tr>
                                            </ItemTemplate>
                                        </asp:Repeater>
                                    </tbody>
                                </table>
                            </div>

                            <div class="p-2 bg-light rounded small text-muted border">
                                <ul class="mb-0 ps-3">
                                    <li>Refunds are credited back to the original method of payment.</li>
                                    <li>Rescheduling allows one complimentary date change if done 15+ days prior.</li>
                                    <li>Blocked tickets automatically expire after 48 hours without penalty.</li>
                                </ul>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </asp:Panel>
    </div>
</asp:Content>


