<%@ Page Title="Reschedule Ticket - Airline Reservation System" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeFile="RescheduleTicket.aspx.cs" Inherits="RescheduleTicket" EnableEventValidation="false" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .flight-option-card {
            cursor: pointer;
            transition: all 0.2s ease-in-out;
            border: 2px solid #e9ecef;
        }
        .flight-option-card:hover {
            border-color: #0d6efd;
            background-color: #f8f9fa;
        }
        .flight-option-card.selected {
            border-color: #0d6efd;
            background-color: #e7f1ff;
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
                <li class="breadcrumb-item active" aria-current="page">Reschedule Ticket</li>
            </ol>
        </nav>

        <div class="ars-card p-4 mb-4 bg-white border-0 shadow-sm border-start border-info border-4">
            <div class="d-flex justify-content-between align-items-center mb-3 flex-wrap gap-2">
                <div>
                    <span class="badge bg-info text-white mb-1"><i class="fa-solid fa-calendar-days me-1"></i> Phase 8 Module</span>
                    <h2 class="fw-bold mb-0 text-dark"><i class="fa-solid fa-arrows-rotate text-primary me-2"></i> Reschedule Flight Ticket</h2>
                    <p class="text-muted mb-0">Change your travel dates for confirmed reservations. Select an alternate flight, adjust fare difference, and receive your new confirmation number.</p>
                </div>
                <div>
                    <span class="badge bg-warning-subtle text-dark border border-warning px-3 py-2">
                        <i class="fa-solid fa-lock text-warning me-1"></i>
                        <strong>Important Rule:</strong> Only confirmed tickets can be rescheduled. Blocked tickets must be confirmed first.
                    </span>
                </div>
            </div>

            <!-- Workflow Visualizer -->
            <div class="p-3 bg-light rounded-3 mb-4 border">
                <div class="row text-center g-2 small">
                    <div class="col-6 col-md-3">
                        <div class="p-2 rounded bg-white shadow-sm border">
                            <span class="badge bg-primary text-white mb-1">Step 1</span>
                            <div class="fw-bold text-dark"><i class="fa-solid fa-ticket text-primary me-1"></i> Enter CNF #</div>
                            <small class="text-muted">Confirmed tickets only</small>
                        </div>
                    </div>
                    <div class="col-6 col-md-3">
                        <div class="p-2 rounded bg-white shadow-sm border">
                            <span class="badge bg-info text-white mb-1">Step 2</span>
                            <div class="fw-bold text-dark"><i class="fa-solid fa-calendar text-info me-1"></i> New Dates</div>
                            <small class="text-muted">Departure &amp; return</small>
                        </div>
                    </div>
                    <div class="col-6 col-md-3">
                        <div class="p-2 rounded bg-white shadow-sm border">
                            <span class="badge bg-warning text-dark mb-1">Step 3</span>
                            <div class="fw-bold text-dark"><i class="fa-solid fa-scale-balanced text-warning me-1"></i> Price Difference</div>
                            <small class="text-muted">Extra charge or refund</small>
                        </div>
                    </div>
                    <div class="col-6 col-md-3">
                        <div class="p-2 rounded bg-white shadow-sm border">
                            <span class="badge bg-success text-white mb-1">Step 4</span>
                            <div class="fw-bold text-dark"><i class="fa-solid fa-check-double text-success me-1"></i> New Ticket (CNF)</div>
                            <small class="text-muted">Seats adjusted &amp; issued</small>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Step 1: Input Confirmation Number Form -->
            <div class="card p-3 bg-light border mb-4">
                <label class="form-label fw-bold text-dark mb-2">
                    <i class="fa-solid fa-magnifying-glass text-primary me-1"></i> Enter Existing Confirmation Number (CNF-XXXXX):
                </label>
                <div class="row g-2 align-items-center">
                    <div class="col-md-8">
                        <div class="input-group">
                            <span class="input-group-text bg-white fw-bold text-muted"><i class="fa-solid fa-hashtag"></i></span>
                            <asp:TextBox ID="txtConfirmationNumber" runat="server" CssClass="form-control form-control-lg fw-bold text-primary" placeholder="e.g. CNF-45872 or CNF-75598"></asp:TextBox>
                            <asp:Button ID="btnRetrieveTicket" runat="server" Text="Retrieve Confirmed Ticket" CssClass="btn btn-primary btn-lg px-4" OnClick="btnRetrieveTicket_Click" />
                        </div>
                    </div>
                    <div class="col-md-4 text-md-end">
                        <asp:Button ID="btnResetForm" runat="server" Text="Clear" CssClass="btn btn-outline-secondary" OnClick="btnResetForm_Click" Visible="false" />
                        <a href="Dashboard.aspx" class="btn btn-outline-primary ms-1"><i class="fa-solid fa-gauge-high me-1"></i> Dashboard</a>
                    </div>
                </div>
            </div>

            <!-- Alert / Status Message Panel -->
            <asp:Panel ID="pnlAlertMessage" runat="server" Visible="false" CssClass="alert alert-dismissible mb-4">
                <asp:Literal ID="litAlertMessage" runat="server"></asp:Literal>
            </asp:Panel>

            <!-- Step 2: Current Ticket Details & New Date Selection -->
            <asp:Panel ID="pnlTicketDetails" runat="server" Visible="false" CssClass="ars-card border border-info p-4 bg-light mb-4">
                <div class="d-flex justify-content-between align-items-center mb-3 pb-2 border-bottom flex-wrap gap-2">
                    <div>
                        <span class="badge bg-success me-2 fs-6">
                            <i class="fa-solid fa-circle-check me-1"></i> Current Ticket: <asp:Literal ID="litOldRef" runat="server"></asp:Literal>
                        </span>
                        <span class="badge bg-primary"><asp:Literal ID="litSeatClass" runat="server"></asp:Literal> Class</span>
                    </div>
                    <div class="text-end">
                        <span class="text-muted small">Passenger:</span> <strong><asp:Literal ID="litPassengerName" runat="server"></asp:Literal></strong>
                    </div>
                </div>

                <div class="row g-4 mb-4">
                    <!-- Current Flight Card -->
                    <div class="col-md-6">
                        <div class="bg-white p-3 rounded border h-100">
                            <div class="text-muted small text-uppercase fw-bold mb-2">Original Booked Flight</div>
                            <h5 class="fw-bold text-dark mb-1"><asp:Literal ID="litOldFlight" runat="server"></asp:Literal></h5>
                            <div class="text-muted small mb-3">
                                <span class="fw-semibold text-primary"><asp:Literal ID="litOldOrigin" runat="server"></asp:Literal></span> &rarr; 
                                <span class="fw-semibold text-primary"><asp:Literal ID="litOldDest" runat="server"></asp:Literal></span>
                            </div>
                            <div class="row g-2 small">
                                <div class="col-6">
                                    <span class="text-muted d-block">Original Departure</span>
                                    <strong class="text-dark"><asp:Literal ID="litOldDepDate" runat="server"></asp:Literal></strong>
                                </div>
                                <div class="col-6 text-end">
                                    <span class="text-muted d-block">Original Fare Paid</span>
                                    <strong class="fs-6 text-success">PKR <asp:Literal ID="litOldPrice" runat="server"></asp:Literal></strong>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- New Travel Dates Picker -->
                    <div class="col-md-6">
                        <div class="bg-white p-3 rounded border h-100 d-flex flex-column justify-content-between">
                            <div>
                                <div class="text-muted small text-uppercase fw-bold mb-2"><i class="fa-solid fa-calendar-plus text-primary me-1"></i> Select New Travel Date</div>
                                <div class="mb-3">
                                    <label class="form-label small fw-semibold text-muted mb-1">New Departure Date:</label>
                                    <asp:TextBox ID="txtNewDepartureDate" runat="server" TextMode="Date" CssClass="form-control fw-bold"></asp:TextBox>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label small fw-semibold text-muted mb-1">New Return Date (Optional for Round-Trip):</label>
                                    <asp:TextBox ID="txtNewReturnDate" runat="server" TextMode="Date" CssClass="form-control"></asp:TextBox>
                                </div>
                            </div>
                            <asp:Button ID="btnSearchAlternateFlights" runat="server" Text="Check Available Alternate Flights" CssClass="btn btn-primary w-100 fw-bold py-2" OnClick="btnSearchAlternateFlights_Click" />
                        </div>
                    </div>
                </div>

                <!-- Hidden State Fields -->
                <asp:HiddenField ID="hfReservationId" runat="server" />
                <asp:HiddenField ID="hfUserId" runat="server" />
                <asp:HiddenField ID="hfOldFlightId" runat="server" />
                <asp:HiddenField ID="hfOldPrice" runat="server" />
                <asp:HiddenField ID="hfOriginCity" runat="server" />
                <asp:HiddenField ID="hfDestinationCity" runat="server" />
                <asp:HiddenField ID="hfSeatClass" runat="server" />
                <asp:HiddenField ID="hfSelectedNewFlightId" runat="server" />
                <asp:HiddenField ID="hfSelectedNewPrice" runat="server" />
            </asp:Panel>

            <!-- Step 3: Available Alternate Flights Results -->
            <asp:Panel ID="pnlAlternateFlights" runat="server" Visible="false" CssClass="mb-4">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h5 class="fw-bold mb-0 text-dark"><i class="fa-solid fa-plane-departure text-primary me-2"></i> Available Alternate Flights on Route</h5>
                    <span class="badge bg-secondary">Showing scheduled operational services</span>
                </div>

                <asp:Repeater ID="rptAlternateFlights" runat="server" OnItemCommand="rptAlternateFlights_ItemCommand">
                    <ItemTemplate>
                        <div class="card mb-3 flight-option-card p-3 shadow-sm">
                            <div class="row align-items-center gy-3">
                                <div class="col-md-3">
                                    <span class="badge bg-primary-subtle text-primary border border-primary mb-1"><%# Eval("AirlineName") %></span>
                                    <h5 class="fw-bold mb-0"><%# Eval("FlightNumber") %></h5>
                                    <small class="text-muted"><%# Eval("OriginCity") %> &rarr; <%# Eval("DestinationCity") %></small>
                                </div>
                                <div class="col-md-3 text-md-center">
                                    <div class="fw-bold text-dark"><%# Convert.ToDateTime(Eval("DepartureTime")).ToString("dd-MMM-yyyy hh:mm tt") %></div>
                                    <small class="text-muted">Duration: <%# Eval("DurationFormatted") %></small>
                                </div>
                                <div class="col-md-2 text-md-center">
                                    <span class="badge bg-success-subtle text-success border border-success">
                                        <i class="fa-solid fa-chair me-1"></i> <%# Eval("AvailableSeats") %> Seats Left
                                    </span>
                                </div>
                                <div class="col-md-2 text-md-end">
                                    <div class="text-muted small">New Flight Fare:</div>
                                    <div class="fw-bold text-dark fs-5">PKR <%# Convert.ToDecimal(Eval("ApplicablePrice")).ToString("N2") %></div>
                                </div>
                                <div class="col-md-2 text-end">
                                    <asp:Button ID="btnSelectFlight" runat="server" CommandName="SelectFlight" 
                                                CommandArgument='<%# Eval("FlightId") + ";" + Eval("ApplicablePrice") + ";" + Eval("FlightNumber") + ";" + Convert.ToDateTime(Eval("DepartureTime")).ToString("dd-MMM-yyyy hh:mm tt") %>'
                                                Text="Select Flight" CssClass="btn btn-outline-primary w-100 fw-bold" />
                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>

                <asp:Panel ID="pnlNoAlternateFlights" runat="server" Visible="false" CssClass="alert alert-warning text-center py-4">
                    <i class="fa-solid fa-triangle-exclamation fa-2x mb-2"></i>
                    <h5>No Alternate Flights Found</h5>
                    <p class="mb-0">No alternate operational flights with open seats were found for the selected route and date. Please try another date.</p>
                </asp:Panel>
            </asp:Panel>

            <!-- Step 4: Fare Difference Breakdown & Reschedule Confirmation -->
            <asp:Panel ID="pnlConfirmReschedule" runat="server" Visible="false" CssClass="card border-primary p-4 bg-white mb-4 shadow-sm">
                <h4 class="fw-bold text-dark mb-3"><i class="fa-solid fa-calculator text-primary me-2"></i> Fare Difference &amp; Seat Adjustment Review</h4>

                <div class="row g-4 mb-3">
                    <div class="col-md-4">
                        <div class="p-3 bg-light rounded border">
                            <span class="text-muted small d-block">Original Ticket Fare Paid:</span>
                            <span class="fs-5 fw-bold text-dark">PKR <asp:Literal ID="litReviewOldPrice" runat="server"></asp:Literal></span>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="p-3 bg-light rounded border">
                            <span class="text-muted small d-block">New Selected Flight Fare:</span>
                            <span class="fs-5 fw-bold text-primary">PKR <asp:Literal ID="litReviewNewPrice" runat="server"></asp:Literal></span>
                            <small class="text-muted d-block mt-1">Flight: <asp:Literal ID="litReviewNewFlightNum" runat="server"></asp:Literal> (<asp:Literal ID="litReviewNewDepDate" runat="server"></asp:Literal>)</small>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="p-3 rounded border" id="divAdjustmentCard" runat="server">
                            <span class="text-muted small d-block">Net Price Adjustment:</span>
                            <span class="fs-5 fw-bold" id="spnAdjustmentAmount" runat="server">
                                <asp:Literal ID="litReviewDiff" runat="server"></asp:Literal>
                            </span>
                            <small class="d-block mt-1 fw-semibold" id="spnAdjustmentType" runat="server">
                                <asp:Literal ID="litReviewAdjustmentDescription" runat="server"></asp:Literal>
                            </small>
                        </div>
                    </div>
                </div>

                <!-- Seat Inventory Notice per Requirement -->
                <div class="alert alert-info py-2 px-3 small mb-3">
                    <i class="fa-solid fa-circle-info me-1"></i>
                    <strong>Automated Seat Reallocation:</strong>
                    Upon confirmation, your old flight seat will be released (+1 available seat), and a seat on the new flight will be reserved (-1 available seat).
                </div>

                <div class="d-flex gap-2 justify-content-end">
                    <asp:Button ID="btnConfirmRescheduleAction" runat="server" Text="Confirm Reschedule &amp; Issue New Confirmation #" 
                                CssClass="btn btn-success btn-lg fw-bold px-4" OnClick="btnConfirmRescheduleAction_Click" />
                </div>
            </asp:Panel>

            <!-- Success Panel: New Ticket Generated -->
            <asp:Panel ID="pnlRescheduleSuccess" runat="server" Visible="false" CssClass="alert alert-success border-success p-4 mb-4">
                <div class="d-flex align-items-center mb-3">
                    <div class="bg-success text-white p-3 rounded-circle me-3">
                        <i class="fa-solid fa-circle-check fa-2x"></i>
                    </div>
                    <div>
                        <h4 class="alert-heading fw-bold mb-1">Flight Ticket Rescheduled Successfully!</h4>
                        <p class="mb-0 text-muted">Your booking has been updated and a new official confirmation number has been generated.</p>
                    </div>
                </div>

                <div class="row g-3 bg-white p-3 rounded border text-dark mb-3">
                    <div class="col-sm-6 col-md-3">
                        <small class="text-muted d-block">Previous Confirmation #</small>
                        <code class="fs-6 text-muted"><asp:Literal ID="litSuccessOldCnf" runat="server"></asp:Literal></code>
                    </div>
                    <div class="col-sm-6 col-md-3">
                        <small class="text-muted d-block text-success fw-bold">New Confirmation #</small>
                        <span class="fs-5 fw-bold text-success"><asp:Literal ID="litSuccessNewCnf" runat="server"></asp:Literal></span>
                    </div>
                    <div class="col-sm-6 col-md-3">
                        <small class="text-muted d-block">Seat Inventory Update</small>
                        <span class="badge bg-primary">Old +1 Seat &bull; New -1 Seat</span>
                    </div>
                    <div class="col-sm-6 col-md-3">
                        <small class="text-muted d-block">Price Difference Outcome</small>
                        <span class="badge bg-warning text-dark"><asp:Literal ID="litSuccessDiffOutcome" runat="server"></asp:Literal></span>
                    </div>
                </div>

                <div class="small text-muted mb-3">
                    <strong>Reschedule Pipeline Executed:</strong>
                    <code>Old CNF (<asp:Literal ID="litPipelineOldCnf" runat="server"></asp:Literal>)</code> &rarr; 
                    <code>Inventory Reallocated (Old Flight +1, New Flight -1)</code> &rarr; 
                    <code>Fare Difference Adjusted</code> &rarr; 
                    <code>New Confirmation Issued (<asp:Literal ID="litPipelineNewCnf" runat="server"></asp:Literal>)</code>
                </div>

                <div class="d-flex gap-2">
                    <a href="Dashboard.aspx" class="btn btn-success fw-bold"><i class="fa-solid fa-gauge-high me-1"></i> Return to Dashboard</a>
                    <a href="RescheduleTicket.aspx" class="btn btn-outline-secondary">Reschedule Another Ticket</a>
                </div>
            </asp:Panel>
        </div>
    </div>
</asp:Content>
