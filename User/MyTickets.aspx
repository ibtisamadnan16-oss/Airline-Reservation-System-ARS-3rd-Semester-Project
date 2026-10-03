<%@ Page Title="My Tickets & Bookings - AeroFly ARS" Language="C#" MasterPageFile="~/Shared/Site.Master" AutoEventWireup="true" CodeFile="MyTickets.aspx.cs" Inherits="User_MyTickets" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container py-4">
        <nav aria-label="breadcrumb" class="mb-3">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="<%= ResolveUrl("~/User/Dashboard.aspx") %>">Dashboard</a></li>
                <li class="breadcrumb-item active" aria-current="page">My Tickets &amp; Bookings</li>
            </ol>
        </nav>

        <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2">
            <div>
                <h2 class="fw-bold mb-1"><i class="fa-solid fa-receipt text-primary me-2"></i>My Bookings &amp; Tickets</h2>
                <p class="text-muted mb-0">View all your confirmed reservations, blocked tickets, and travel history.</p>
            </div>
            <a href="<%= ResolveUrl("~/User/SearchFlights.aspx") %>" class="btn btn-primary-custom">
                <i class="fa-solid fa-plane-circle-check me-2"></i>Book New Flight
            </a>
        </div>

        <div class="ars-card p-4">
            <asp:Panel ID="pnlAlert" runat="server" Visible="false" CssClass="alert alert-info mb-4">
                <asp:Literal ID="litAlertMsg" runat="server"></asp:Literal>
            </asp:Panel>

            <asp:Repeater ID="rptBookings" runat="server">
                <HeaderTemplate>
                    <div class="table-responsive">
                        <table class="table table-hover align-middle border">
                            <thead class="table-light">
                                <tr>
                                    <th>Ref / PNR</th>
                                    <th>Flight</th>
                                    <th>Route</th>
                                    <th>Departure</th>
                                    <th>Passengers</th>
                                    <th>Total Paid</th>
                                    <th>Status</th>
                                    <th class="text-center">Action</th>
                                </tr>
                            </thead>
                            <tbody>
                </HeaderTemplate>
                <ItemTemplate>
                    <tr>
                        <td>
                            <strong class="text-primary font-monospace"><%# Eval("ConfirmationNumber") %></strong>
                            <div class="small text-muted"><%# Convert.ToDateTime(Eval("BookingDate")).ToString("dd MMM yyyy") %></div>
                        </td>
                        <td>
                            <strong><%# Eval("FlightNumber") %></strong>
                            <div class="small text-muted"><%# Eval("TravelClass") %></div>
                        </td>
                        <td>
                            <span class="badge bg-primary-subtle text-primary"><%# Eval("OriginCity") %></span>
                            <i class="fa-solid fa-arrow-right mx-1 text-muted"></i>
                            <span class="badge bg-danger-subtle text-danger"><%# Eval("DestinationCity") %></span>
                        </td>
                        <td>
                            <div class="small fw-semibold"><%# Convert.ToDateTime(Eval("DepartureTime")).ToString("dd MMM yyyy, hh:mm tt") %></div>
                        </td>
                        <td>
                            <span class="badge bg-secondary-subtle text-dark"><%# Eval("PassengerCount") %> Seats</span>
                        </td>
                        <td class="fw-bold text-success">
                            PKR <%# string.Format("{0:N0}", Eval("TotalPrice")) %>
                        </td>
                        <td>
                            <span class='badge <%# GetStatusBadgeClass(Eval("Status").ToString()) %>'>
                                <%# Eval("Status") %>
                            </span>
                        </td>
                        <td class="text-center">
                            <a href='<%# ResolveUrl("~/User/TicketStatus.aspx?code=" + Eval("ConfirmationNumber")) %>' class="btn btn-sm btn-outline-primary me-1" title="View Details">
                                <i class="fa-solid fa-eye"></i>
                            </a>
                            <%# GetActionButtons(Eval("ConfirmationNumber").ToString(), Eval("Status").ToString()) %>
                        </td>
                    </tr>
                </ItemTemplate>
                <FooterTemplate>
                            </tbody>
                        </table>
                    </div>
                </FooterTemplate>
            </asp:Repeater>
        </div>
    </div>
</asp:Content>

