<%@ Page Title="Users Management - AeroFly Operations" Language="C#" MasterPageFile="~/Shared/Site.Master" AutoEventWireup="true" CodeFile="Users.aspx.cs" Inherits="Admin_Users" EnableEventValidation="false" %>

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
                <i class="fa-solid fa-users-gear me-1"></i> Access Control
            </span>
            <h1 class="display-6 fw-bold mb-1 text-white">Registered Users &amp; Roles</h1>
            <p class="text-white-50 mb-0">Manage registered passenger profiles, SkyMiles loyalty rewards, and Clerk/Administrator privileges.</p>
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
                    <a class="nav-link active" href="<%= ResolveUrl("~/Admin/Users.aspx") %>">
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

        <div class="ars-card p-4">
            <h5 class="fw-bold mb-3"><i class="fa-solid fa-id-card text-primary me-2"></i>Registered Member Profiles</h5>
            <div class="table-responsive">
                <asp:GridView ID="gvUsers" runat="server" AutoGenerateColumns="false" CssClass="table table-hover align-middle border mb-0"
                    DataKeyNames="UserId" OnRowCommand="gvUsers_RowCommand">
                    <Columns>
                        <asp:BoundField DataField="Username" HeaderText="Username" ItemStyle-CssClass="fw-bold font-monospace" />
                        <asp:TemplateField HeaderText="Full Name">
                            <ItemTemplate>
                                <%# Eval("FirstName") %> <%# Eval("LastName") %>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="Email" HeaderText="Email" />
                        <asp:BoundField DataField="PhoneNumber" HeaderText="Phone" />
                        <asp:TemplateField HeaderText="Role">
                            <ItemTemplate>
                                <span class='badge <%# Eval("Role").ToString() == "Admin" ? "bg-danger" : (Eval("Role").ToString() == "Clerk" ? "bg-warning text-dark" : "bg-primary") %>'>
                                    <%# Eval("Role") %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="SkyMiles" HeaderText="SkyMiles" ItemStyle-CssClass="fw-bold text-warning" />
                        <asp:BoundField DataField="CreatedAt" HeaderText="Registered" DataFormatString="{0:dd MMM yyyy}" />
                        <asp:TemplateField HeaderText="Actions" ItemStyle-CssClass="text-end">
                            <ItemTemplate>
                                <asp:LinkButton ID="btnMakeClerk" runat="server" CommandName="MakeClerk" CommandArgument='<%# Eval("UserId") %>'
                                    CssClass="btn btn-sm btn-outline-warning me-1" ToolTip="Set Clerk Role">
                                    <i class="fa-solid fa-user-tie"></i>
                                </asp:LinkButton>
                                <asp:LinkButton ID="btnMakeAdmin" runat="server" CommandName="MakeAdmin" CommandArgument='<%# Eval("UserId") %>'
                                    CssClass="btn btn-sm btn-outline-danger me-1" ToolTip="Promote to Admin">
                                    <i class="fa-solid fa-shield-halved"></i>
                                </asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </div>
</asp:Content>

