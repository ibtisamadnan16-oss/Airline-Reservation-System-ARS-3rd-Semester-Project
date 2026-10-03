<%@ Page Title="Cancel Ticket - AeroFly Airline Reservation System" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeFile="CancelTicket.aspx.cs" Inherits="CancelTicket" EnableEventValidation="false" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .policy-card {
            border-left: 4px solid #dc3545;
        }
        .refund-badge {
            font-size: 1.1rem;
            font-weight: 700;
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container py-4">
        <!-- Breadcrumbs -->
        <nav aria-label="breadcrumb" class="mb-3">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="Default.aspx">Home</a></li>
                <li class="breadcrumb-item"><a href="Dashboard.aspx">Dashboard</a></li>
                <li class="breadcrumb-item active" aria-current="page">Cancel Ticket</li>
            </ol>
        </nav>

        <div class="ars-card p-4 mb-4 bg-white border-0 shadow-sm border-start border-danger border-4">
            <div class="d-flex justify-content-between align-items-center mb-3 flex-wrap gap-2">
                <div>
                    <span class="badge bg-danger text-white mb-1"><i class="fa-solid fa-ban me-1"></i> Phase 9 Module</span>
                    <h2 class="fw-bold mb-0 text-dark"><i class="fa-solid fa-rectangle-xmark text-danger me-2"></i> Ticket Cancellation &amp; Refund</h2>
                    <p class="text-muted mb-0">Cancel blocked reservations or confirmed tickets with automated policy refund calculation and seat inventory restoration.</p>
                </div>
                <div>
                    <a href="Dashboard.aspx" class="btn btn-outline-secondary"><i class="fa-solid fa-arrow-left me-1"></i> Back to Dashboard</a>
                </div>
            </div>

            <!-- Workflow Visualizer -->
            <div class="p-3 bg-light rounded-3 mb-4 border">
                <div class="row text-center g-2 small">
                    <div class="col-6 col-md-3">
                        <div class="p-2 rounded bg-white shadow-sm border">
                            <span class="badge bg-primary text-white mb-1">Step 1</span>
                            <div class="fw-bold text-dark"><i class="fa-solid fa-hashtag text-primary me-1"></i> Enter Reference</div>
                            <small class="text-muted">BLK-XXXXX or CNF-XXXXX</small>
                        </div>
                    </div>
                    <div class="col-6 col-md-3">
                        <div class="p-2 rounded bg-white shadow-sm border">
                            <span class="badge bg-warning text-dark mb-1">Step 2</span>
                            <div class="fw-bold text-dark"><i class="fa-solid fa-scale-balanced text-warning me-1"></i> Policy &amp; Refund</div>
                            <small class="text-muted">Automated refund % check</small>
                        </div>
                    </div>
                    <div class="col-6 col-md-3">
                        <div class="p-2 rounded bg-white shadow-sm border">
                            <span class="badge bg-danger text-white mb-1">Step 3</span>
                            <div class="fw-bold text-dark"><i class="fa-solid fa-ban text-danger me-1"></i> Confirm Cancel</div>
                            <small class="text-muted">Seats +1 &amp; Miles -350</small>
                        </div>
                    </div>
                    <div class="col-6 col-md-3">
                        <div class="p-2 rounded bg-white shadow-sm border">
                            <span class="badge bg-success text-white mb-1">Step 4</span>
                            <div class="fw-bold text-dark"><i class="fa-solid fa-receipt text-success me-1"></i> CAN-XXXXX Issued</div>
                            <small class="text-muted">Cancellation receipt generated</small>
                        </div>
                    </div>
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
                    <i class="fa-solid fa-magnifying-glass text-danger me-1"></i> Enter Booking Reference Number (BLK-XXXXX or CNF-XXXXX):
                </label>
                <div class="row g-2 align-items-center">
                    <div class="col-md-8">
                        <div class="input-group">
                            <span class="input-group-text bg-white fw-bold text-muted"><i class="fa-solid fa-ticket"></i></span>
                            <asp:TextBox ID="txtBookingReference" runat="server" CssClass="form-control form-control-lg fw-bold text-uppercase" placeholder="e.g. BLK-90823 or CNF-45872"></asp:TextBox>
                            <asp:Button ID="btnLookupTicket" runat="server" Text="Retrieve Reservation" CssClass="btn btn-danger btn-lg px-4 fw-bold" OnClick="btnLookupTicket_Click" />
                        </div>
                    </div>
                    <div class="col-md-4 text-md-end">
                        <asp:Button ID="btnClearLookup" runat="server" Text="Clear" CssClass="btn btn-outline-secondary" OnClick="btnClearLookup_Click" Visible="false" />
                    </div>
                </div>
                <small class="text-muted mt-2 d-block">
                    <i class="fa-solid fa-circle-info me-1"></i> Both <strong>Blocked Reservations (BLK)</strong> and <strong>Confirmed Tickets (CNF)</strong> can be retrieved and cancelled here.
                </small>
            </div>

            <!-- HIDDEN FIELDS FOR STATE RETENTION -->
            <asp:HiddenField ID="hfReservationId" runat="server" />
            <asp:HiddenField ID="hfUserId" runat="server" />
            <asp:HiddenField ID="hfFlightId" runat="server" />
            <asp:HiddenField ID="hfBookingReference" runat="server" />
            <asp:HiddenField ID="hfTicketType" runat="server" />
            <asp:HiddenField ID="hfTotalPrice" runat="server" />
            <asp:HiddenField ID="hfRefundAmount" runat="server" />
            <asp:HiddenField ID="hfSkyMilesToDeduct" runat="server" />

            <!-- PANEL: CASE 1 - BLOCKED TICKET CANCELLATION -->
            <asp:Panel ID="pnlBlockedTicket" runat="server" Visible="false" CssClass="mb-4">
                <div class="card border-warning shadow-sm">
                    <div class="card-header bg-warning-subtle text-dark d-flex justify-content-between align-items-center py-3">
                        <div>
                            <span class="badge bg-warning text-dark me-2 fs-6">Blocked Reservation</span>
                            <strong class="fs-5 text-dark"><asp:Literal ID="litBlockedRef" runat="server"></asp:Literal></strong>
                        </div>
                        <span class="badge bg-dark"><i class="fa-solid fa-shield me-1"></i> Case 1: Seat Blocking Cancellation</span>
                    </div>
                    <div class="card-body">
                        <!-- Flight & Passenger Info -->
                        <div class="row g-3 mb-3">
                            <div class="col-md-3">
                                <label class="text-muted small">Flight Number</label>
                                <div class="fw-bold fs-5 text-primary"><asp:Literal ID="litBlockedFlightNumber" runat="server"></asp:Literal></div>
                                <small class="text-muted"><asp:Literal ID="litBlockedAirline" runat="server"></asp:Literal></small>
                            </div>
                            <div class="col-md-4">
                                <label class="text-muted small">Route</label>
                                <div class="fw-bold"><asp:Literal ID="litBlockedRoute" runat="server"></asp:Literal></div>
                                <small class="text-muted"><asp:Literal ID="litBlockedSchedule" runat="server"></asp:Literal></small>
                            </div>
                            <div class="col-md-3">
                                <label class="text-muted small">Passenger / Class</label>
                                <div class="fw-bold"><asp:Literal ID="litBlockedPassenger" runat="server"></asp:Literal></div>
                                <span class="badge bg-secondary"><asp:Literal ID="litBlockedClass" runat="server"></asp:Literal></span>
                            </div>
                            <div class="col-md-2">
                                <label class="text-muted small">Departure In</label>
                                <div class="fw-bold text-dark"><asp:Literal ID="litBlockedDays" runat="server"></asp:Literal> days</div>
                            </div>
                        </div>

                        <!-- Cancellation Policy Notice for Blocked Tickets -->
                        <div class="alert alert-info border-info d-flex align-items-center mb-4">
                            <i class="fa-solid fa-info-circle fa-2x text-info me-3"></i>
                            <div>
                                <h6 class="fw-bold mb-1">Blocked Reservation Cancellation Rules:</h6>
                                <ul class="mb-0 small">
                                    <li><strong>No Payment Charged:</strong> Since this was a blocked ticket, no credit card transaction was processed. No cancellation fee applies.</li>
                                    <li><strong>Seats Restore (+1):</strong> The blocked seat will be immediately returned back to the flight inventory for other passengers.</li>
                                    <li><strong>SkyMiles Unchanged:</strong> SkyMiles were not awarded during seat blocking, so member mileage remains unaffected.</li>
                                </ul>
                            </div>
                        </div>

                        <!-- Cancellation Action Button -->
                        <div class="d-flex justify-content-end gap-2">
                            <asp:Button ID="btnCancelBlockedTicket" runat="server" Text="Confirm Block Cancellation & Release Seat" CssClass="btn btn-warning text-dark fw-bold px-4 py-2" OnClick="btnCancelBlockedTicket_Click" />
                        </div>
                    </div>
                </div>
            </asp:Panel>

            <!-- PANEL: CASE 2 - CONFIRMED TICKET CANCELLATION -->
            <asp:Panel ID="pnlConfirmedTicket" runat="server" Visible="false" CssClass="mb-4">
                <div class="card border-danger shadow-sm">
                    <div class="card-header bg-danger text-white d-flex justify-content-between align-items-center py-3">
                        <div>
                            <span class="badge bg-white text-danger me-2 fs-6">Confirmed Ticket</span>
                            <strong class="fs-5"><asp:Literal ID="litConfirmedRef" runat="server"></asp:Literal></strong>
                        </div>
                        <span class="badge bg-light text-dark"><i class="fa-solid fa-shield-halved me-1"></i> Case 2: Confirmed Ticket Refund Policy</span>
                    </div>
                    <div class="card-body">
                        <!-- Flight & Passenger Summary -->
                        <div class="row g-3 mb-4 p-3 bg-light rounded-3 border">
                            <div class="col-md-3">
                                <label class="text-muted small">Flight Number</label>
                                <div class="fw-bold fs-5 text-primary"><asp:Literal ID="litConfirmedFlightNumber" runat="server"></asp:Literal></div>
                                <small class="text-muted"><asp:Literal ID="litConfirmedAirline" runat="server"></asp:Literal></small>
                            </div>
                            <div class="col-md-4">
                                <label class="text-muted small">Route</label>
                                <div class="fw-bold"><asp:Literal ID="litConfirmedRoute" runat="server"></asp:Literal></div>
                                <small class="text-muted"><asp:Literal ID="litConfirmedSchedule" runat="server"></asp:Literal></small>
                            </div>
                            <div class="col-md-3">
                                <label class="text-muted small">Passenger / Class</label>
                                <div class="fw-bold"><asp:Literal ID="litConfirmedPassenger" runat="server"></asp:Literal></div>
                                <span class="badge bg-primary"><asp:Literal ID="litConfirmedClass" runat="server"></asp:Literal></span>
                            </div>
                            <div class="col-md-2">
                                <label class="text-muted small">Days to Departure</label>
                                <div class="fw-bold fs-5 text-danger"><asp:Literal ID="litConfirmedDays" runat="server"></asp:Literal> days</div>
                            </div>
                        </div>

                        <!-- Applicable Cancellation Policies Table -->
                        <h5 class="fw-bold mb-3 text-dark"><i class="fa-solid fa-table-list text-primary me-2"></i> Airline Cancellation &amp; Refund Policy Matrix</h5>
                        <div class="table-responsive mb-4">
                            <table class="table table-bordered table-hover align-middle">
                                <thead class="table-dark">
                                    <tr>
                                        <th>Cancellation Period</th>
                                        <th class="text-center">Refund %</th>
                                        <th class="text-center">Cancellation Fee %</th>
                                        <th>Status / Applicability</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr id="rowPolicy30" runat="server">
                                        <td class="fw-bold">30+ days before departure</td>
                                        <td class="text-center fw-bold text-success fs-6">90%</td>
                                        <td class="text-center text-muted">10%</td>
                                        <td><asp:Literal ID="litBadgePolicy30" runat="server" Text="<span class='badge bg-secondary'>Applicable if &gt;= 30 days</span>"></asp:Literal></td>
                                    </tr>
                                    <tr id="rowPolicy15" runat="server">
                                        <td class="fw-bold">15 to 30 days before departure</td>
                                        <td class="text-center fw-bold text-primary fs-6">70%</td>
                                        <td class="text-center text-muted">30%</td>
                                        <td><asp:Literal ID="litBadgePolicy15" runat="server" Text="<span class='badge bg-secondary'>Applicable if 15-30 days</span>"></asp:Literal></td>
                                    </tr>
                                    <tr id="rowPolicyLess15" runat="server">
                                        <td class="fw-bold">Less than 15 days before departure</td>
                                        <td class="text-center fw-bold text-warning fs-6">40%</td>
                                        <td class="text-center text-muted">60%</td>
                                        <td><asp:Literal ID="litBadgePolicyLess15" runat="server" Text="<span class='badge bg-secondary'>Applicable if 1-14 days</span>"></asp:Literal></td>
                                    </tr>
                                    <tr id="rowPolicy24h" runat="server">
                                        <td class="fw-bold">Within 24 hours of departure / Passed</td>
                                        <td class="text-center fw-bold text-danger fs-6">0%</td>
                                        <td class="text-center text-danger">100%</td>
                                        <td><asp:Literal ID="litBadgePolicy24h" runat="server" Text="<span class='badge bg-secondary'>Non-refundable</span>"></asp:Literal></td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>

                        <!-- Calculated Refund Breakdown Card -->
                        <div class="row g-3 mb-4">
                            <div class="col-md-7">
                                <div class="p-3 bg-light rounded-3 border h-100">
                                    <h6 class="fw-bold text-dark mb-3"><i class="fa-solid fa-calculator text-primary me-2"></i> Calculated Refund Breakdown</h6>
                                    <div class="d-flex justify-content-between mb-2">
                                        <span class="text-muted">Original Ticket Paid Fare:</span>
                                        <span class="fw-bold">PKR <asp:Literal ID="litOriginalPrice" runat="server"></asp:Literal></span>
                                    </div>
                                    <div class="d-flex justify-content-between mb-2">
                                        <span class="text-muted">Applicable Refund Rate:</span>
                                        <span class="fw-bold text-success"><asp:Literal ID="litRefundPercentage" runat="server"></asp:Literal>%</span>
                                    </div>
                                    <div class="d-flex justify-content-between mb-2 text-danger">
                                        <span>Cancellation Fee Deduction (<asp:Literal ID="litPenaltyPercentage" runat="server"></asp:Literal>%):</span>
                                        <span class="fw-bold">- PKR <asp:Literal ID="litCancellationFee" runat="server"></asp:Literal></span>
                                    </div>
                                    <hr class="my-2" />
                                    <div class="d-flex justify-content-between align-items-center mb-0">
                                        <span class="fw-bold fs-6 text-dark">Net Refund Credit to Card / Account:</span>
                                        <span class="fw-bold fs-5 text-success">PKR <asp:Literal ID="litNetRefundAmount" runat="server"></asp:Literal></span>
                                    </div>
                                </div>
                            </div>

                            <div class="col-md-5">
                                <div class="p-3 bg-light rounded-3 border h-100">
                                    <h6 class="fw-bold text-dark mb-3"><i class="fa-solid fa-list-check text-primary me-2"></i> System Actions on Cancellation</h6>
                                    <ul class="list-unstyled mb-0 small">
                                        <li class="mb-2">
                                            <i class="fa-solid fa-circle-check text-success me-2"></i>
                                            <strong>Cancellation Number:</strong> A new <code class="text-danger fw-bold">CAN-XXXXX</code> reference will be issued.
                                        </li>
                                        <li class="mb-2">
                                            <i class="fa-solid fa-circle-plus text-primary me-2"></i>
                                            <strong>Available Seats +:</strong> 1 seat immediately restored to flight inventory.
                                        </li>
                                        <li class="mb-2">
                                            <i class="fa-solid fa-hand-holding-dollar text-success me-2"></i>
                                            <strong>Refund Credit:</strong> Credited according to policy refund rate.
                                        </li>
                                        <li class="mb-0">
                                            <i class="fa-solid fa-circle-minus text-danger me-2"></i>
                                            <strong>Sky Miles -:</strong> <span class="badge bg-danger">-350 SkyMiles</span> deducted from user balance.
                                        </li>
                                    </ul>
                                </div>
                            </div>
                        </div>

                        <!-- Confirmation Action -->
                        <div class="d-flex justify-content-end gap-2">
                            <asp:Button ID="btnConfirmCancellation" runat="server" Text="Confirm Cancellation & Issue Refund" CssClass="btn btn-danger btn-lg fw-bold px-4 py-2" OnClick="btnConfirmCancellation_Click" />
                        </div>
                    </div>
                </div>
            </asp:Panel>

            <!-- PANEL: SUCCESS RECEIPT PANEL -->
            <asp:Panel ID="pnlSuccessReceipt" runat="server" Visible="false" CssClass="mb-4">
                <div class="card border-success shadow">
                    <div class="card-header bg-success text-white py-3 text-center">
                        <i class="fa-solid fa-circle-check fa-3x mb-2 d-block"></i>
                        <h3 class="fw-bold mb-0">Ticket Successfully Cancelled!</h3>
                        <p class="mb-0">Your cancellation transaction has been completed and processed according to airline rules.</p>
                    </div>
                    <div class="card-body p-4">
                        <div class="row justify-content-center mb-4">
                            <div class="col-md-8 text-center p-3 bg-light rounded-3 border">
                                <label class="text-muted small text-uppercase fw-bold">Generated Cancellation Number</label>
                                <div class="display-6 fw-bold text-danger my-1 font-monospace"><asp:Literal ID="litResultCancellationNumber" runat="server"></asp:Literal></div>
                                <span class="badge bg-danger-subtle text-danger border border-danger px-3 py-1">Status: Cancelled</span>
                            </div>
                        </div>

                        <div class="row g-3 mb-4">
                            <div class="col-md-3">
                                <div class="p-3 bg-light rounded-3 text-center border">
                                    <small class="text-muted d-block">Previous Reference</small>
                                    <strong class="text-dark fs-6 font-monospace"><asp:Literal ID="litResultOldReference" runat="server"></asp:Literal></strong>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="p-3 bg-light rounded-3 text-center border">
                                    <small class="text-muted d-block">Inventory Restored</small>
                                    <strong class="text-primary fs-6"><i class="fa-solid fa-chair text-primary me-1"></i> +1 Seat Restored</strong>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="p-3 bg-light rounded-3 text-center border">
                                    <small class="text-muted d-block">Refund Credited</small>
                                    <strong class="text-success fs-6">PKR <asp:Literal ID="litResultRefundAmount" runat="server"></asp:Literal></strong>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="p-3 bg-light rounded-3 text-center border">
                                    <small class="text-muted d-block">Sky Miles Deducted</small>
                                    <strong class="text-danger fs-6"><i class="fa-solid fa-plane-slash text-danger me-1"></i> -<asp:Literal ID="litResultSkyMilesDeducted" runat="server"></asp:Literal> Miles</strong>
                                </div>
                            </div>
                        </div>

                        <div class="text-center gap-2 d-flex justify-content-center">
                            <a href="Dashboard.aspx" class="btn btn-primary px-4 py-2"><i class="fa-solid fa-gauge-high me-1"></i> Go to Dashboard</a>
                            <a href="SearchFlights.aspx" class="btn btn-outline-primary px-4 py-2"><i class="fa-solid fa-magnifying-glass me-1"></i> Book New Flight</a>
                        </div>
                    </div>
                </div>
            </asp:Panel>
        </div>
    </div>
</asp:Content>
