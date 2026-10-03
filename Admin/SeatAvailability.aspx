<%@ Page Title="Seat Availability - AeroFly Operations" Language="C#" MasterPageFile="~/Shared/Site.Master" AutoEventWireup="true" CodeFile="SeatAvailability.aspx.cs" Inherits="Admin_SeatAvailability" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .admin-hero {
            background: linear-gradient(135deg, #1e1e2f 0%, #2d2d44 100%);
            border-radius: 1rem;
            color: #fff;
            padding: 1.75rem 2rem;
            margin-bottom: 1.5rem;
            border-left: 6px solid #e11d48;
        }
        .admin-hero h1, .admin-hero h2, .admin-hero .display-6 {
            color: #ffffff !important;
            text-shadow: 0 2px 12px rgba(0, 0, 0, 0.6) !important;
        }
        .nav-admin-tabs .nav-link {
            font-weight: 600;
            color: #475569;
            padding: 0.75rem 1.25rem;
            border: none;
            border-bottom: 3px solid transparent;
            border-radius: 0;
            background: transparent;
        }
        .nav-admin-tabs .nav-link.active {
            color: #e11d48;
            border-bottom: 3px solid #e11d48;
            background: transparent;
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container-fluid py-4 px-md-5">
        <div class="admin-hero shadow-sm">
            <span class="badge bg-danger text-white px-3 py-1 rounded-pill fw-bold text-uppercase mb-2">
                <i class="fa-solid fa-chair me-1"></i> Fleet Inventory
            </span>
            <h1 class="display-6 fw-bold mb-1 text-white">Live Seat Availability Monitor</h1>
            <p class="text-white-50 mb-0">Track real-time capacity, seat deductions from confirmed bookings &amp; temporary blocks.</p>
        </div>

            <div class="card border-0 shadow-sm rounded-3 overflow-hidden mb-4">
        <div class="card-header bg-white border-bottom p-0">
            <ul class="nav nav-tabs nav-admin-tabs px-3">
                <li class="nav-item">
                    <a class="nav-link " href="<%= ResolveUrl("~/Admin/Dashboard.aspx") %>">
                        <i class="fa-solid fa-gauge-high me-1"></i> Dashboard Overview
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link " href="<%= ResolveUrl("~/Admin/Flights.aspx") %>">
                        <i class="fa-solid fa-plane-departure me-1"></i> Flights
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link " href="<%= ResolveUrl("~/Admin/FlightSchedules.aspx") %>">
                        <i class="fa-solid fa-calendar-days me-1"></i> Flight Schedules
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link " href="<%= ResolveUrl("~/Admin/Reservations.aspx") %>">
                        <i class="fa-solid fa-receipt me-1"></i> Reservations
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link " href="<%= ResolveUrl("~/Admin/Users.aspx") %>">
                        <i class="fa-solid fa-user-gear me-1"></i> Users
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link active" href="<%= ResolveUrl("~/Admin/SeatAvailability.aspx") %>">
                        <i class="fa-solid fa-chart-pie me-1"></i> Seat Availability
                    </a>
                </li>
            </ul>
        </div>
    </div>

        <div class="ars-card p-4">
            <h5 class="fw-bold mb-3"><i class="fa-solid fa-chart-pie text-primary me-2"></i>Real-Time Aircraft Seat Inventories</h5>
            <div class="table-responsive">
                <asp:GridView ID="gvSeatAvailability" runat="server" AutoGenerateColumns="false" CssClass="table table-hover align-middle border mb-0">
                    <Columns>
                        <asp:BoundField DataField="FlightNumber" HeaderText="Flight #" ItemStyle-CssClass="fw-bold font-monospace text-primary" />
                        <asp:BoundField DataField="OriginCity" HeaderText="Origin" />
                        <asp:BoundField DataField="DestinationCity" HeaderText="Destination" />
                        <asp:BoundField DataField="DepartureTime" HeaderText="Departure" DataFormatString="{0:dd MMM, hh:mm tt}" />
                        <asp:BoundField DataField="TotalSeats" HeaderText="Total Capacity" ItemStyle-CssClass="text-center" />
                        <asp:BoundField DataField="AvailableSeats" HeaderText="Available Seats" ItemStyle-CssClass="fw-bold text-success text-center" />
                        <asp:TemplateField HeaderText="Occupancy Progress" ItemStyle-CssClass="w-25">
                            <ItemTemplate>
                                <%# GetProgressBar(Eval("TotalSeats"), Eval("AvailableSeats")) %>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </div>
</asp:Content>

