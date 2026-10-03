<%@ Page Title="Confirm Blocked Ticket - Airline Reservation System" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeFile="ConfirmBlockedTicket.aspx.cs" Inherits="ConfirmBlockedTicket" EnableEventValidation="false" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container py-4">
        <!-- Breadcrumb navigation -->
        <nav aria-label="breadcrumb" class="mb-3">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="Default.aspx">Home</a></li>
                <li class="breadcrumb-item"><a href="Dashboard.aspx">Dashboard</a></li>
                <li class="breadcrumb-item active" aria-current="page">Confirm Blocked Ticket</li>
            </ol>
        </nav>

        <div class="ars-card p-4 mb-4 bg-white border-0 shadow-sm border-start border-primary border-4">
            <div class="d-flex justify-content-between align-items-center mb-3 flex-wrap gap-2">
                <div>
                    <span class="badge bg-primary text-white mb-1"><i class="fa-solid fa-ticket me-1"></i> Phase 7 Module</span>
                    <h2 class="fw-bold mb-0 text-dark"><i class="fa-solid fa-circle-check text-success me-2"></i> Confirm Blocked Ticket</h2>
                    <p class="text-muted mb-0">Retrieve your blocked seat, verify the 2-week advance confirmation rule, settle fare payment, and issue your official Confirmed Ticket.</p>
                </div>
                <div>
                    <span class="badge bg-warning-subtle text-dark border border-warning px-3 py-2">
                        <i class="fa-solid fa-triangle-exclamation text-warning me-1"></i>
                        <strong>Mandatory Policy:</strong> Blocked tickets must be confirmed &ge; 2 weeks (14 days) prior to departure.
                    </span>
                </div>
            </div>

            <!-- Workflow Visualizer -->
            <div class="p-3 bg-light rounded-3 mb-4 border">
                <div class="row text-center g-2 small">
                    <div class="col-6 col-md-3">
                        <div class="p-2 rounded bg-white shadow-sm border">
                            <span class="badge bg-warning text-dark mb-1">Step 1</span>
                            <div class="fw-bold text-dark"><i class="fa-solid fa-lock text-warning me-1"></i> Block Ticket</div>
                            <small class="text-muted">Hold reference issued</small>
                        </div>
                    </div>
                    <div class="col-6 col-md-3">
                        <div class="p-2 rounded bg-white shadow-sm border">
                            <span class="badge bg-info text-white mb-1">Step 2</span>
                            <div class="fw-bold text-dark"><i class="fa-solid fa-calendar-check text-info me-1"></i> 2-Week Check</div>
                            <small class="text-muted">Departure &ge; 14 Days</small>
                        </div>
                    </div>
                    <div class="col-6 col-md-3">
                        <div class="p-2 rounded bg-white shadow-sm border">
                            <span class="badge bg-primary text-white mb-1">Step 3</span>
                            <div class="fw-bold text-dark"><i class="fa-solid fa-credit-card text-primary me-1"></i> Payment Charge</div>
                            <small class="text-muted">Fare settlement</small>
                        </div>
                    </div>
                    <div class="col-6 col-md-3">
                        <div class="p-2 rounded bg-white shadow-sm border">
                            <span class="badge bg-success text-white mb-1">Step 4</span>
                            <div class="fw-bold text-dark"><i class="fa-solid fa-ticket-simple text-success me-1"></i> Confirmed Ticket</div>
                            <small class="text-muted">Issue CNF-XXXXX</small>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Search Input Form -->
            <div class="card p-3 bg-light border mb-4">
                <label class="form-label fw-bold text-dark mb-2">
                    <i class="fa-solid fa-magnifying-glass text-primary me-1"></i> Enter Blocking Number (BLK-XXXXX):
                </label>
                <div class="row g-2 align-items-center">
                    <div class="col-md-8">
                        <div class="input-group">
                            <span class="input-group-text bg-white fw-bold text-muted"><i class="fa-solid fa-hashtag"></i></span>
                            <asp:TextBox ID="txtBlockingNumber" runat="server" CssClass="form-control form-control-lg fw-bold text-primary" placeholder="e.g. BLK-17891 or BLK-90823"></asp:TextBox>
                            <asp:Button ID="btnRetrieveBlock" runat="server" Text="Retrieve &amp; Verify Ticket" CssClass="btn btn-primary btn-lg px-4" OnClick="btnRetrieveBlock_Click" />
                        </div>
                    </div>
                    <div class="col-md-4 text-md-end">
                        <asp:Button ID="btnResetBlockSearch" runat="server" Text="Clear" CssClass="btn btn-outline-secondary" OnClick="btnResetBlockSearch_Click" Visible="false" />
                        <a href="Dashboard.aspx" class="btn btn-outline-primary ms-1"><i class="fa-solid fa-gauge-high me-1"></i> Return to Dashboard</a>
                    </div>
                </div>
            </div>

            <!-- Alert Message Panel -->
            <asp:Panel ID="pnlBlockMessage" runat="server" Visible="false" CssClass="alert alert-dismissible mb-4">
                <asp:Literal ID="litBlockMessage" runat="server"></asp:Literal>
            </asp:Panel>

            <!-- Block Details Panel (When Ticket Found) -->
            <asp:Panel ID="pnlBlockDetails" runat="server" Visible="false" CssClass="ars-card border border-primary p-4 bg-light mb-4">
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

                <div class="row g-4">
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
                            <div class="p-3 rounded bg-light border small">
                                <strong>2-Week Advance Confirmation Rule Check:</strong>
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
                                    <small class="text-muted">Card charged upon confirmation</small>
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
            <asp:Panel ID="pnlConfirmationSuccess" runat="server" Visible="false" CssClass="alert alert-success border-success p-4 mb-4">
                <div class="d-flex align-items-center mb-3">
                    <div class="bg-success text-white p-3 rounded-circle me-3">
                        <i class="fa-solid fa-circle-check fa-2x"></i>
                    </div>
                    <div>
                        <h4 class="alert-heading fw-bold mb-1">Ticket Confirmed Successfully!</h4>
                        <p class="mb-0 text-muted">Your blocked ticket has completed payment and is officially confirmed. Your confirmation number has been issued.</p>
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
                <div class="small text-muted mb-3">
                    <strong>Executed Pipeline:</strong>
                    <code>Block (<asp:Literal ID="litSuccessPipelineOld" runat="server"></asp:Literal>)</code> &rarr; 
                    <code>Payment Charge Processed</code> &rarr; 
                    <code>Confirmed Ticket</code> &rarr; 
                    <code>Confirmation Number Issued (<asp:Literal ID="litSuccessPipelineCnf" runat="server"></asp:Literal>)</code>
                </div>
                <div class="d-flex gap-2">
                    <a href="Dashboard.aspx" class="btn btn-success fw-bold"><i class="fa-solid fa-gauge-high me-1"></i> Go to Dashboard</a>
                    <a href="ConfirmBlockedTicket.aspx" class="btn btn-outline-secondary">Confirm Another Ticket</a>
                </div>
            </asp:Panel>
        </div>
    </div>
</asp:Content>
