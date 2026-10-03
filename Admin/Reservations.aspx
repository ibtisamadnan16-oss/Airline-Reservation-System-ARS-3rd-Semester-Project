<%@ Page Title="Reservations Overview - AeroFly Operations" Language="C#" MasterPageFile="~/Shared/Site.Master" AutoEventWireup="true" CodeFile="Reservations.aspx.cs" Inherits="Admin_Reservations" %>

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
                <i class="fa-solid fa-receipt me-1"></i> Ticketing Ledger
            </span>
            <h1 class="display-6 fw-bold mb-1 text-white">Passenger Reservations Ledger</h1>
            <p class="text-white-50 mb-0">Search bookings by confirmation or blocking number, filter transactions, and verify passenger bookings.</p>
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
                    <a class="nav-link active" href="<%= ResolveUrl("~/Admin/Reservations.aspx") %>">
                        <i class="fa-solid fa-receipt me-1"></i> Reservations
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link " href="<%= ResolveUrl("~/Admin/Users.aspx") %>">
                        <i class="fa-solid fa-user-gear me-1"></i> Users
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link " href="<%= ResolveUrl("~/Admin/SeatAvailability.aspx") %>">
                        <i class="fa-solid fa-chart-pie me-1"></i> Seat Availability
                    </a>
                </li>
            </ul>
        </div>
    </div>

        <div class="ars-card p-4">
            <div class="row g-3 align-items-center mb-4">
                <div class="col-md-4">
                    <label class="form-label fw-semibold small text-muted text-uppercase mb-1">Filter by Status</label>
                    <asp:DropDownList ID="ddlFilterStatus" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilterStatus_SelectedIndexChanged">
                        <asp:ListItem Value="ALL">All Reservations</asp:ListItem>
                        <asp:ListItem Value="Confirmed">Confirmed Bookings</asp:ListItem>
                        <asp:ListItem Value="Blocked">Blocked Tickets</asp:ListItem>
                        <asp:ListItem Value="Cancelled">Cancelled / Refunded</asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="col-md-5">
                    <label class="form-label fw-semibold small text-muted text-uppercase mb-1">Search by PNR / Blocking Code</label>
                    <div class="input-group">
                        <asp:TextBox ID="txtSearchCode" runat="server" CssClass="form-control" placeholder="e.g. CNF-8921 or BLK-4011" />
                        <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="btn btn-primary-custom" OnClick="btnSearch_Click" />
                    </div>
                </div>
                <div class="col-md-3 text-md-end mt-4">
                    <asp:Button ID="btnReset" runat="server" Text="Reset Filters" CssClass="btn btn-outline-secondary btn-sm" OnClick="btnReset_Click" />
                </div>
            </div>

            <div class="table-responsive">
                <asp:GridView ID="gvReservations" runat="server" AutoGenerateColumns="false" CssClass="table table-hover align-middle border mb-0">
                    <Columns>
                        <asp:BoundField DataField="ConfirmationNumber" HeaderText="PNR / Ref" ItemStyle-CssClass="fw-bold font-monospace text-primary" />
                        <asp:BoundField DataField="PassengerName" HeaderText="Passenger" />
                        <asp:BoundField DataField="FlightNumber" HeaderText="Flight #" />
                        <asp:BoundField DataField="OriginCity" HeaderText="From" />
                        <asp:BoundField DataField="DestinationCity" HeaderText="To" />
                        <asp:BoundField DataField="TravelClass" HeaderText="Class" />
                        <asp:BoundField DataField="PassengerCount" HeaderText="Seats" ItemStyle-CssClass="text-center" />
                        <asp:BoundField DataField="TotalPrice" HeaderText="Price" DataFormatString="PKR {0:N0}" ItemStyle-CssClass="fw-bold text-success" />
                        <asp:TemplateField HeaderText="Status">
                            <ItemTemplate>
                                <span class='badge <%# GetBadge(Eval("Status").ToString()) %>'>
                                    <%# Eval("Status") %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="BookingDate" HeaderText="Date" DataFormatString="{0:dd MMM yyyy}" />
                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </div>
</asp:Content>

