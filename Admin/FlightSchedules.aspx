<%@ Page Title="Flight Schedules - AeroFly Operations" Language="C#" MasterPageFile="~/Shared/Site.Master" AutoEventWireup="true" CodeFile="FlightSchedules.aspx.cs" Inherits="Admin_FlightSchedules" EnableEventValidation="false" %>

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
                <i class="fa-solid fa-clock me-1"></i> Dispatch Control
            </span>
            <h1 class="display-6 fw-bold mb-1 text-white">Flight Schedules &amp; Delay Advisories</h1>
            <p class="text-white-50 mb-0">Control departure/arrival schedules, issue last-minute delay notices, and adjust timetable dates.</p>
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
                    <a class="nav-link active" href="<%= ResolveUrl("~/Admin/FlightSchedules.aspx") %>">
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
                    <a class="nav-link " href="<%= ResolveUrl("~/Admin/SeatAvailability.aspx") %>">
                        <i class="fa-solid fa-chart-pie me-1"></i> Seat Availability
                    </a>
                </li>
            </ul>
        </div>
    </div>

        <asp:Panel ID="pnlAlert" runat="server" Visible="false" CssClass="alert alert-success alert-dismissible fade show" role="alert">
            <asp:Literal ID="litAlertMsg" runat="server"></asp:Literal>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </asp:Panel>

        <div class="row g-4">
            <div class="col-lg-4">
                <div class="ars-card p-4">
                    <h5 class="fw-bold mb-3"><i class="fa-solid fa-pen-to-square text-primary me-2"></i>Adjust Schedule</h5>
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Select Flight</label>
                        <asp:DropDownList ID="ddlScheduleFlight" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlScheduleFlight_SelectedIndexChanged" />
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold">New Departure Time</label>
                        <asp:TextBox ID="txtNewDepTime" runat="server" CssClass="form-control" TextMode="DateTimeLocal" />
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold">New Arrival Time</label>
                        <asp:TextBox ID="txtNewArrTime" runat="server" CssClass="form-control" TextMode="DateTimeLocal" />
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Flight Status Note</label>
                        <asp:DropDownList ID="ddlFlightStatus" runat="server" CssClass="form-select">
                            <asp:ListItem Value="On-Time">On-Time</asp:ListItem>
                            <asp:ListItem Value="Delayed">Delayed</asp:ListItem>
                            <asp:ListItem Value="Boarding">Boarding</asp:ListItem>
                            <asp:ListItem Value="Departed">Departed</asp:ListItem>
                            <asp:ListItem Value="Cancelled">Cancelled</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Delay Reason / Public Advisory</label>
                        <asp:TextBox ID="txtDelayReason" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="2" placeholder="e.g. Weather advisory, Air traffic clearance delayed by 30 mins" />
                    </div>
                    <asp:Button ID="btnUpdateSchedule" runat="server" Text="Broadcast Schedule Update" CssClass="btn btn-primary-custom w-100 fw-bold" OnClick="btnUpdateSchedule_Click" />
                </div>
            </div>

            <div class="col-lg-8">
                <div class="ars-card p-4">
                    <h5 class="fw-bold mb-3"><i class="fa-solid fa-table-list text-primary me-2"></i>Live Dispatch Timetable</h5>
                    <div class="table-responsive">
                        <asp:GridView ID="gvSchedules" runat="server" AutoGenerateColumns="false" CssClass="table table-hover align-middle border mb-0">
                            <Columns>
                                <asp:BoundField DataField="FlightNumber" HeaderText="Flight #" ItemStyle-CssClass="fw-bold text-primary font-monospace" />
                                <asp:BoundField DataField="OriginCity" HeaderText="From" />
                                <asp:BoundField DataField="DestinationCity" HeaderText="To" />
                                <asp:BoundField DataField="DepartureTime" HeaderText="Departure" DataFormatString="{0:dd MMM, hh:mm tt}" />
                                <asp:BoundField DataField="ArrivalTime" HeaderText="Arrival" DataFormatString="{0:dd MMM, hh:mm tt}" />
                                <asp:TemplateField HeaderText="Status">
                                    <ItemTemplate>
                                        <span class='badge <%# Eval("Status").ToString() == "Active" ? "bg-success" : "bg-warning text-dark" %>'>
                                            <%# Eval("Status") %>
                                        </span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

