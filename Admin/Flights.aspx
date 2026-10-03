<%@ Page Title="Flights Management - AeroFly Operations" Language="C#" MasterPageFile="~/Shared/Site.Master" AutoEventWireup="true" CodeFile="Flights.aspx.cs" Inherits="Admin_Flights" EnableEventValidation="false" %>

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
            <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
                <div>
                    <span class="badge bg-danger text-white px-3 py-1 rounded-pill fw-bold text-uppercase mb-2">
                        <i class="fa-solid fa-plane-departure me-1"></i> Commercial Fleet
                    </span>
                    <h1 class="display-6 fw-bold mb-1 text-white">Commercial Flights Management</h1>
                    <p class="text-white-50 mb-0">Add new commercial routes, view flight statuses, and manage airline inventory.</p>
                </div>
                <button type="button" class="btn btn-warning fw-bold" data-bs-toggle="collapse" data-bs-target="#collapseNewFlight">
                    <i class="fa-solid fa-plus me-1"></i> Add Commercial Flight
                </button>
            </div>
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
                    <a class="nav-link active" href="<%= ResolveUrl("~/Admin/Flights.aspx") %>">
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

        <div class="collapse mb-4" id="collapseNewFlight">
            <div class="ars-card p-4 border-start border-4 border-danger">
                <h5 class="fw-bold mb-3"><i class="fa-solid fa-plane-circle-check text-danger me-2"></i>Register New Commercial Flight</h5>
                <div class="row g-3">
                    <div class="col-md-3">
                        <label class="form-label fw-semibold">Flight Number *</label>
                        <asp:TextBox ID="txtFlightNumber" runat="server" CssClass="form-control" placeholder="e.g. PK-301" />
                    </div>
                    <div class="col-md-3">
                        <label class="form-label fw-semibold">Airline Name *</label>
                        <asp:TextBox ID="txtAirlineName" runat="server" CssClass="form-control" Text="AeroFly Express" />
                    </div>
                    <div class="col-md-3">
                        <label class="form-label fw-semibold">Origin City *</label>
                        <asp:TextBox ID="txtOriginCity" runat="server" CssClass="form-control" placeholder="e.g. Karachi" />
                    </div>
                    <div class="col-md-3">
                        <label class="form-label fw-semibold">Destination City *</label>
                        <asp:TextBox ID="txtDestinationCity" runat="server" CssClass="form-control" placeholder="e.g. Islamabad" />
                    </div>
                    <div class="col-md-3">
                        <label class="form-label fw-semibold">Departure Time *</label>
                        <asp:TextBox ID="txtDepartureTime" runat="server" CssClass="form-control" TextMode="DateTimeLocal" />
                    </div>
                    <div class="col-md-3">
                        <label class="form-label fw-semibold">Arrival Time *</label>
                        <asp:TextBox ID="txtArrivalTime" runat="server" CssClass="form-control" TextMode="DateTimeLocal" />
                    </div>
                    <div class="col-md-2">
                        <label class="form-label fw-semibold">Economy Price (PKR)</label>
                        <asp:TextBox ID="txtEconomyPrice" runat="server" CssClass="form-control" Text="15000" />
                    </div>
                    <div class="col-md-2">
                        <label class="form-label fw-semibold">Business Price (PKR)</label>
                        <asp:TextBox ID="txtBusinessPrice" runat="server" CssClass="form-control" Text="28000" />
                    </div>
                    <div class="col-md-2">
                        <label class="form-label fw-semibold">Seats Capacity</label>
                        <asp:TextBox ID="txtSeats" runat="server" CssClass="form-control" Text="120" />
                    </div>
                    <div class="col-12 text-end mt-3">
                        <asp:Button ID="btnSaveFlight" runat="server" Text="Save & Dispatch Flight" CssClass="btn btn-danger px-4 fw-bold" OnClick="btnSaveFlight_Click" />
                    </div>
                </div>
            </div>
        </div>

        <div class="ars-card p-4">
            <h5 class="fw-bold mb-3"><i class="fa-solid fa-list-check text-primary me-2"></i>Active Commercial Flights Inventory</h5>
            <div class="table-responsive">
                <asp:GridView ID="gvFlights" runat="server" AutoGenerateColumns="false" CssClass="table table-hover align-middle border mb-0"
                    DataKeyNames="FlightId" OnRowCommand="gvFlights_RowCommand">
                    <Columns>
                        <asp:BoundField DataField="FlightNumber" HeaderText="Flight #" ItemStyle-CssClass="fw-bold text-primary font-monospace" />
                        <asp:BoundField DataField="AirlineName" HeaderText="Airline" />
                        <asp:BoundField DataField="OriginCity" HeaderText="Origin" />
                        <asp:BoundField DataField="DestinationCity" HeaderText="Destination" />
                        <asp:BoundField DataField="DepartureTime" HeaderText="Departure" DataFormatString="{0:dd MMM yyyy, hh:mm tt}" />
                        <asp:BoundField DataField="ArrivalTime" HeaderText="Arrival" DataFormatString="{0:dd MMM yyyy, hh:mm tt}" />
                        <asp:BoundField DataField="AvailableSeats" HeaderText="Available Seats" ItemStyle-CssClass="fw-bold text-center" />
                        <asp:BoundField DataField="EconomyPrice" HeaderText="Economy" DataFormatString="PKR {0:N0}" />
                        <asp:TemplateField HeaderText="Status">
                            <ItemTemplate>
                                <span class='badge <%# Eval("Status").ToString() == "Active" ? "bg-success" : "bg-warning text-dark" %>'>
                                    <%# Eval("Status") %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Actions" ItemStyle-CssClass="text-end">
                            <ItemTemplate>
                                <asp:LinkButton ID="btnToggleStatus" runat="server" CommandName="ToggleStatus" CommandArgument='<%# Eval("FlightId") %>'
                                    CssClass="btn btn-sm btn-outline-secondary me-1" ToolTip="Toggle Status">
                                    <i class="fa-solid fa-power-off"></i>
                                </asp:LinkButton>
                                <asp:LinkButton ID="btnDeleteFlight" runat="server" CommandName="DeleteFlight" CommandArgument='<%# Eval("FlightId") %>'
                                    CssClass="btn btn-sm btn-outline-danger" ToolTip="Cancel / Delete Flight" OnClientClick="return confirm('Cancel this commercial flight?');">
                                    <i class="fa-solid fa-trash"></i>
                                </asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </div>
</asp:Content>

