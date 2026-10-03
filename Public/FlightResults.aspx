<%@ Page Title="Available Flight Results - Airline Reservation System" Language="C#" MasterPageFile="~/Shared/Site.Master" AutoEventWireup="true" CodeFile="FlightResults.aspx.cs" Inherits="Public_FlightResults" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .flight-row-selected {
            background-color: #e0f2fe !important;
            border-left: 4px solid #0284c7 !important;
        }
        .selection-card {
            background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%);
            color: #fff;
            border-radius: 12px;
            box-shadow: 0 10px 25px rgba(0,0,0,0.15);
        }
        .flight-badge {
            font-size: 0.9rem;
            letter-spacing: 0.5px;
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container py-4">
        <nav aria-label="breadcrumb" class="mb-3">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="<%= ResolveUrl("~/Public/Home.aspx") %>">Home</a></li>
                <li class="breadcrumb-item"><a href="<%= ResolveUrl("~/Public/SearchFlights.aspx") %>">Flight Search</a></li>
                <li class="breadcrumb-item active" aria-current="page">Flight Results</li>
            </ol>
        </nav>

        <div class="ars-card mb-4 p-4 bg-white border-0 shadow-sm">
            <div class="row align-items-center gy-3">
                <div class="col-lg-8">
                    <div class="d-flex align-items-center flex-wrap gap-2 mb-2">
                        <span class="badge bg-primary px-3 py-2 fs-6">
                            <i class="fa-solid fa-plane-departure me-1"></i> <asp:Literal ID="litOriginCity" runat="server"></asp:Literal>
                        </span>
                        <i class="fa-solid fa-arrow-right-long text-muted fa-lg"></i>
                        <span class="badge bg-danger px-3 py-2 fs-6">
                            <i class="fa-solid fa-plane-arrival me-1"></i> <asp:Literal ID="litDestinationCity" runat="server"></asp:Literal>
                        </span>
                        <span class="badge bg-secondary-subtle text-dark border ms-2">
                            <asp:Literal ID="litTripTypeBadge" runat="server"></asp:Literal>
                        </span>
                        <span class="badge bg-light text-secondary border">
                            <asp:Literal ID="litClassBadge" runat="server"></asp:Literal>
                        </span>
                    </div>

                    <div class="text-muted small">
                        <span class="me-3"><i class="fa-solid fa-calendar me-1 text-primary"></i> <strong>Depart:</strong> <asp:Literal ID="litDepDateDisplay" runat="server"></asp:Literal></span>
                        <asp:PlaceHolder ID="phReturnDateSummary" runat="server" Visible="false">
                            <span class="me-3"><i class="fa-solid fa-calendar-check me-1 text-danger"></i> <strong>Return:</strong> <asp:Literal ID="litRetDateDisplay" runat="server"></asp:Literal></span>
                        </asp:PlaceHolder>
                        <span><i class="fa-solid fa-users me-1 text-dark"></i> <strong>Passengers:</strong> <asp:Literal ID="litPassengerSummary" runat="server"></asp:Literal></span>
                    </div>
                </div>

                <div class="col-lg-4 text-lg-end">
                    <a href="<%= ResolveUrl("~/Public/SearchFlights.aspx") %>" class="btn btn-outline-primary btn-sm">
                        <i class="fa-solid fa-pen-to-square me-1"></i> Modify Flight Search
                    </a>
                </div>
            </div>
        </div>

        <asp:Panel ID="pnlAlert" runat="server" Visible="false" CssClass="alert alert-warning mb-4">
            <i class="fa-solid fa-triangle-exclamation me-2"></i>
            <asp:Literal ID="litAlertMsg" runat="server"></asp:Literal>
        </asp:Panel>

        <div class="ars-card mb-5">
            <div class="card-header-custom d-flex justify-content-between align-items-center flex-wrap gap-2">
                <div>
                    <h5 class="fw-bold mb-0 text-white">
                        <i class="fa-solid fa-plane-departure me-2"></i> Onward Flights: <asp:Literal ID="litOnwardRouteTitle" runat="server"></asp:Literal>
                    </h5>
                    <small class="text-white-50">Departure Date: <asp:Literal ID="litOnwardDateTitle" runat="server"></asp:Literal></small>
                </div>
                <span class="badge bg-light text-dark"><asp:Literal ID="litOnwardCount" runat="server">0</asp:Literal> Flights Available</span>
            </div>

            <div class="p-4">
                <asp:Panel ID="pnlNoOnward" runat="server" Visible="false" CssClass="text-center py-4">
                    <i class="fa-solid fa-plane-slash fa-2x text-muted mb-2"></i>
                    <h6 class="fw-bold">No Direct Onward Flights Found</h6>
                    <p class="text-muted small">No scheduled flights match this exact date. Try another date or check connecting routes below.</p>
                </asp:Panel>

                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-light">
                            <tr class="text-uppercase small text-muted">
                                <th style="width: 60px;" class="text-center">Select</th>
                                <th>Flight</th>
                                <th>Departure</th>
                                <th>Arrival</th>
                                <th>Duration</th>
                                <th>Available Seats</th>
                                <th>Class Fares</th>
                            </tr>
                        </thead>
                        <tbody>
                            <asp:Repeater ID="rptOnwardFlights" runat="server" OnItemCommand="rptOnwardFlights_ItemCommand">
                                <ItemTemplate>
                                    <tr class='<%# IsOnwardSelected(Eval("FlightId")) ? "flight-row-selected" : "" %>'>
                                        <td class="text-center">
                                            <asp:LinkButton ID="btnSelectOnward" runat="server"
                                                CommandName="SelectOnward"
                                                CommandArgument='<%# Eval("FlightId") + "|" + Eval("FlightNumber") + "|" + Eval("EconomyPrice") + "|" + Eval("DepartureTime") + "|" + Eval("ArrivalTime") %>'
                                                CssClass='<%# IsOnwardSelected(Eval("FlightId")) ? "btn btn-sm btn-primary" : "btn btn-sm btn-outline-secondary" %>'>
                                                <i class='<%# IsOnwardSelected(Eval("FlightId")) ? "fa-solid fa-circle-check" : "fa-regular fa-circle" %>'></i>
                                            </asp:LinkButton>
                                        </td>
                                        <td>
                                            <div class="fw-bold text-primary flight-badge">
                                                <i class="fa-solid fa-plane me-1"></i><%# Eval("FlightNumber") %>
                                            </div>
                                            <small class="text-muted"><%# Eval("AirlineName") %></small>
                                        </td>
                                        <td>
                                            <div class="fs-5 fw-bold text-dark"><%# Convert.ToDateTime(Eval("DepartureTime")).ToString("hh:mm tt") %></div>
                                            <small class="text-muted"><%# Eval("OriginCity") %></small>
                                        </td>
                                        <td>
                                            <div class="fs-5 fw-bold text-dark"><%# Convert.ToDateTime(Eval("ArrivalTime")).ToString("hh:mm tt") %></div>
                                            <small class="text-muted"><%# Eval("DestinationCity") %></small>
                                        </td>
                                        <td>
                                            <span class="badge bg-light text-dark border px-2 py-1">
                                                <i class="fa-regular fa-clock me-1 text-primary"></i><%# FormatDuration(Eval("DepartureTime"), Eval("ArrivalTime")) %>
                                            </span>
                                        </td>
                                        <td>
                                            <span class="badge bg-info-subtle text-info-emphasis border">
                                                <%# Eval("AvailableSeats") %> Seats
                                            </span>
                                        </td>
                                        <td>
                                            <div class="fw-bold text-success fs-6">
                                                PKR <%# string.Format("{0:N0}", Eval("EconomyPrice")) %> <span class="small text-muted fw-normal">Econ</span>
                                            </div>
                                            <small class="text-muted">
                                                Biz: PKR <%# string.Format("{0:N0}", Eval("BusinessPrice")) %>
                                            </small>
                                        </td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <asp:Panel ID="pnlReturnSection" runat="server" Visible="false" CssClass="ars-card mb-5">
            <div class="card-header-custom d-flex justify-content-between align-items-center flex-wrap gap-2" style="background: linear-gradient(135deg, #1e3a8a, #0369a1);">
                <div>
                    <h5 class="fw-bold mb-0 text-white">
                        <i class="fa-solid fa-plane-arrival me-2"></i> Return Flights: <asp:Literal ID="litReturnRouteTitle" runat="server"></asp:Literal>
                    </h5>
                    <small class="text-white-50">Return Date: <asp:Literal ID="litReturnDateTitle" runat="server"></asp:Literal></small>
                </div>
                <span class="badge bg-light text-dark"><asp:Literal ID="litReturnCount" runat="server">0</asp:Literal> Flights Available</span>
            </div>

            <div class="p-4">
                <asp:Panel ID="pnlNoReturn" runat="server" Visible="false" CssClass="text-center py-4">
                    <i class="fa-solid fa-plane-slash fa-2x text-muted mb-2"></i>
                    <h6 class="fw-bold">No Direct Return Flights Found</h6>
                    <p class="text-muted small">No scheduled return flights match this exact return date.</p>
                </asp:Panel>

                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-light">
                            <tr class="text-uppercase small text-muted">
                                <th style="width: 60px;" class="text-center">Select</th>
                                <th>Flight</th>
                                <th>Departure</th>
                                <th>Arrival</th>
                                <th>Duration</th>
                                <th>Available Seats</th>
                                <th>Class Fares</th>
                            </tr>
                        </thead>
                        <tbody>
                            <asp:Repeater ID="rptReturnFlights" runat="server" OnItemCommand="rptReturnFlights_ItemCommand">
                                <ItemTemplate>
                                    <tr class='<%# IsReturnSelected(Eval("FlightId")) ? "flight-row-selected" : "" %>'>
                                        <td class="text-center">
                                            <asp:LinkButton ID="btnSelectReturn" runat="server"
                                                CommandName="SelectReturn"
                                                CommandArgument='<%# Eval("FlightId") + "|" + Eval("FlightNumber") + "|" + Eval("EconomyPrice") + "|" + Eval("DepartureTime") + "|" + Eval("ArrivalTime") %>'
                                                CssClass='<%# IsReturnSelected(Eval("FlightId")) ? "btn btn-sm btn-primary" : "btn btn-sm btn-outline-secondary" %>'>
                                                <i class='<%# IsReturnSelected(Eval("FlightId")) ? "fa-solid fa-circle-check" : "fa-regular fa-circle" %>'></i>
                                            </asp:LinkButton>
                                        </td>
                                        <td>
                                            <div class="fw-bold text-primary flight-badge">
                                                <i class="fa-solid fa-plane fa-flip-horizontal me-1"></i><%# Eval("FlightNumber") %>
                                            </div>
                                            <small class="text-muted"><%# Eval("AirlineName") %></small>
                                        </td>
                                        <td>
                                            <div class="fs-5 fw-bold text-dark"><%# Convert.ToDateTime(Eval("DepartureTime")).ToString("hh:mm tt") %></div>
                                            <small class="text-muted"><%# Eval("OriginCity") %></small>
                                        </td>
                                        <td>
                                            <div class="fs-5 fw-bold text-dark"><%# Convert.ToDateTime(Eval("ArrivalTime")).ToString("hh:mm tt") %></div>
                                            <small class="text-muted"><%# Eval("DestinationCity") %></small>
                                        </td>
                                        <td>
                                            <span class="badge bg-light text-dark border px-2 py-1">
                                                <i class="fa-regular fa-clock me-1 text-primary"></i><%# FormatDuration(Eval("DepartureTime"), Eval("ArrivalTime")) %>
                                            </span>
                                        </td>
                                        <td>
                                            <span class="badge bg-info-subtle text-info-emphasis border">
                                                <%# Eval("AvailableSeats") %> Seats
                                            </span>
                                        </td>
                                        <td>
                                            <div class="fw-bold text-success fs-6">
                                                PKR <%# string.Format("{0:N0}", Eval("EconomyPrice")) %> <span class="small text-muted fw-normal">Econ</span>
                                            </div>
                                            <small class="text-muted">
                                                Biz: PKR <%# string.Format("{0:N0}", Eval("BusinessPrice")) %>
                                            </small>
                                        </td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>
                        </tbody>
                    </table>
                </div>
            </div>
        </asp:Panel>

        <asp:Panel ID="pnlSelectionSummary" runat="server" CssClass="selection-card p-4 mb-4">
            <div class="row align-items-center gy-3">
                <div class="col-lg-8">
                    <h5 class="fw-bold mb-2 text-warning"><i class="fa-solid fa-clipboard-check me-2"></i>Selected Flight Itinerary</h5>

                    <div class="row g-2">
                        <div class="col-sm-6">
                            <div class="p-2 bg-dark rounded border border-secondary">
                                <small class="text-muted d-block text-uppercase fw-semibold">Onward Flight</small>
                                <asp:Literal ID="litSelectedOnwardInfo" runat="server"><em>Please select an onward flight above</em></asp:Literal>
                            </div>
                        </div>

                        <div class="col-sm-6">
                            <div class="p-2 bg-dark rounded border border-secondary">
                                <small class="text-muted d-block text-uppercase fw-semibold">Return Flight</small>
                                <asp:Literal ID="litSelectedReturnInfo" runat="server"><em>N/A (One-Way Trip)</em></asp:Literal>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-lg-4 text-lg-end">
                    <small class="text-white-50 d-block">Estimated Total Fare (All Passengers):</small>
                    <div class="display-6 fw-bold text-success mb-3">
                        PKR <asp:Literal ID="litGrandTotal" runat="server">0</asp:Literal>
                    </div>

                    <% if (AirlineReservationSystem.UserStateHelper.IsLoggedIn) { %>
                        <div class="d-flex gap-2 justify-content-lg-end">
                            <asp:Button ID="btnProceedBooking" runat="server" Text="Proceed to Book"
                                CssClass="btn btn-success fw-bold px-4" OnClick="btnProceedBooking_Click" />
                            <asp:Button ID="btnBlockSeat" runat="server" Text="Block Seat"
                                CssClass="btn btn-warning text-dark fw-bold px-3" OnClick="btnBlockSeat_Click" />
                        </div>
                    <% } else { %>
                        <div class="alert alert-warning py-2 px-3 small text-dark mb-2 text-start">
                            <i class="fa-solid fa-lock me-1"></i>
                            <strong>Guest Mode:</strong> You can view flight availability. To buy or block tickets, please log in.
                        </div>
                        <div class="d-flex gap-2 justify-content-lg-end">
                            <a href="<%= ResolveUrl("~/Public/Login.aspx?msg=auth_required") %>" class="btn btn-warning text-dark fw-bold btn-sm">
                                <i class="fa-solid fa-right-to-bracket me-1"></i> Login to Book
                            </a>
                            <a href="Register.aspx" class="btn btn-outline-light btn-sm">
                                <i class="fa-solid fa-user-plus me-1"></i> Register
                            </a>
                        </div>
                    <% } %>
                </div>
            </div>
        </asp:Panel>
    </div>
</asp:Content>

