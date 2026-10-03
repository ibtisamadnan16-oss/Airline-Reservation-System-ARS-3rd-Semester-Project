<%@ Page Title="Guest Mode - Airline Reservation System" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeFile="Guest.aspx.cs" Inherits="Guest" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container py-4">
        <!-- Guest Notification Banner -->
        <div class="alert alert-warning border-warning d-flex align-items-center justify-content-between p-4 mb-4 rounded-3 shadow-sm">
            <div class="d-flex align-items-center">
                <i class="fa-solid fa-user-secret fa-3x text-warning me-3"></i>
                <div>
                    <h4 class="alert-heading fw-bold mb-1">Browsing in Guest Mode</h4>
                    <p class="mb-0 text-dark">
                        As specified in Section 3.1.1.2 of the project document, guest passengers have access to view 
                        <strong>flight schedules, ticket pricing, and seat availability</strong>.
                        To <strong>block</strong>, <strong>reserve</strong>, or <strong>manage tickets</strong>, registration is required.
                    </p>
                </div>
            </div>
            <div class="text-nowrap ms-3">
                <a href="Register.aspx" class="btn btn-warning text-dark fw-bold">
                    <i class="fa-solid fa-user-plus me-1"></i> Register Account
                </a>
            </div>
        </div>

        <!-- Guest Available Features vs Restricted Features -->
        <div class="row g-4 mb-4">
            <div class="col-md-6">
                <div class="ars-card p-4 border-start border-success border-5">
                    <h5 class="fw-bold text-success mb-3"><i class="fa-solid fa-circle-check me-2"></i> What You Can Do as Guest:</h5>
                    <ul class="list-group list-group-flush">
                        <li class="list-group-item bg-transparent"><i class="fa-solid fa-check text-success me-2"></i> Search all flights between origin and destination cities</li>
                        <li class="list-group-item bg-transparent"><i class="fa-solid fa-check text-success me-2"></i> View flight departure/arrival timings and schedule</li>
                        <li class="list-group-item bg-transparent"><i class="fa-solid fa-check text-success me-2"></i> Inspect seat counts (Economy, Business, First Class)</li>
                        <li class="list-group-item bg-transparent"><i class="fa-solid fa-check text-success me-2"></i> Compare ticket prices &amp; promotional fares</li>
                    </ul>
                </div>
            </div>
            <div class="col-md-6">
                <div class="ars-card p-4 border-start border-danger border-5">
                    <h5 class="fw-bold text-danger mb-3"><i class="fa-solid fa-circle-xmark me-2"></i> Restricted for Guest (Registration Required):</h5>
                    <ul class="list-group list-group-flush">
                        <li class="list-group-item bg-transparent"><i class="fa-solid fa-xmark text-danger me-2"></i> <strong>Seat Blocking:</strong> Cannot hold/block a seat prior to purchase</li>
                        <li class="list-group-item bg-transparent"><i class="fa-solid fa-xmark text-danger me-2"></i> <strong>Ticket Purchase:</strong> Cannot execute reservation transactions</li>
                        <li class="list-group-item bg-transparent"><i class="fa-solid fa-xmark text-danger me-2"></i> <strong>Ticket Management:</strong> Cannot confirm, reschedule, or cancel tickets</li>
                        <li class="list-group-item bg-transparent"><i class="fa-solid fa-xmark text-danger me-2"></i> <strong>SkyMiles:</strong> Frequent flyer miles cannot be accumulated</li>
                    </ul>
                </div>
            </div>
        </div>

        <!-- Direct Flight Availability Table for Guest -->
        <div class="ars-card">
            <div class="card-header-custom d-flex justify-content-between align-items-center">
                <span class="fs-5"><i class="fa-solid fa-plane-departure me-2"></i> Live Flight Availability (Guest View)</span>
                <a href="Default.aspx#search-flights" class="btn btn-sm btn-outline-light">
                    <i class="fa-solid fa-magnifying-glass me-1"></i> Filter Route
                </a>
            </div>
            <div class="p-4">
                <asp:Repeater ID="rptGuestFlights" runat="server">
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
                                        <th>Economy</th>
                                        <th>Business</th>
                                        <th class="text-center">Status</th>
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
                                <span class="badge bg-info text-dark"><%# Eval("AvailableSeats") %> seats available</span>
                            </td>
                            <td class="fw-bold text-success">PKR <%# string.Format("{0:N0}", Eval("EconomyPrice")) %></td>
                            <td class="fw-bold text-primary">PKR <%# string.Format("{0:N0}", Eval("BusinessPrice")) %></td>
                            <td class="text-center">
                                <span class="badge bg-secondary">
                                    <i class="fa-solid fa-eye me-1"></i> Available (Guest View)
                                </span>
                            </td>
                        </tr>
                    </ItemTemplate>
                    <FooterTemplate>
                                </tbody>
                            </table>
                        </div>
                    </FooterTemplate>
                </asp:Repeater>

                <div class="text-center mt-4">
                    <a href="Register.aspx" class="btn btn-warning px-4 py-2 text-dark fw-bold me-2">
                        <i class="fa-solid fa-user-plus me-1"></i> Register to Book Flights
                    </a>
                    <a href="Login.aspx" class="btn btn-outline-primary px-4 py-2">
                        <i class="fa-solid fa-right-to-bracket me-1"></i> Existing User Login
                    </a>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
