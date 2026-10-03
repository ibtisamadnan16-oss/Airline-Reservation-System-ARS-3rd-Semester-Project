<%@ Page Title="Sign In - Airline Reservation System" Language="C#" MasterPageFile="~/Shared/Site.Master" AutoEventWireup="true" CodeFile="Login.aspx.cs" Inherits="Public_Login" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container py-5">
        <div class="row justify-content-center">
            <div class="col-md-7 col-lg-5">
                <div class="ars-card">
                    <div class="card-header-custom text-center py-4">
                        <i class="fa-solid fa-plane-departure fa-2x mb-2 text-warning"></i>
                        <h3 class="fw-bold mb-1">Passenger Login</h3>
                        <p class="small mb-0 text-white-50">Access your AeroFly profile &amp; reservations</p>
                    </div>

                    <div class="p-4 p-md-5">
                        <asp:Panel ID="pnlAlert" runat="server" Visible="false" CssClass="alert alert-danger mb-4">
                            <i class="fa-solid fa-triangle-exclamation me-2"></i>
                            <asp:Literal ID="litAlertMsg" runat="server"></asp:Literal>
                        </asp:Panel>

                        <!-- Login Form Controls -->
                        <div class="mb-3">
                            <label class="form-label fw-semibold">
                                <i class="fa-solid fa-user me-1 text-primary"></i> User ID / Username
                            </label>
                            <asp:TextBox ID="txtUsername" runat="server" CssClass="form-control form-control-lg" placeholder="e.g. john_doe" />
                            <asp:RequiredFieldValidator ID="rfvUsername" runat="server" ControlToValidate="txtUsername"
                                ErrorMessage="Username / User ID is required." CssClass="text-danger small" Display="Dynamic" />
                        </div>

                        <div class="mb-4">
                            <label class="form-label fw-semibold">
                                <i class="fa-solid fa-lock me-1 text-primary"></i> Password
                            </label>
                            <asp:TextBox ID="txtPassword" runat="server" CssClass="form-control form-control-lg" TextMode="Password" placeholder="Enter password" />
                            <asp:RequiredFieldValidator ID="rfvPassword" runat="server" ControlToValidate="txtPassword"
                                ErrorMessage="Password is required." CssClass="text-danger small" Display="Dynamic" />
                        </div>

                        <div class="d-flex justify-content-between align-items-center mb-4">
                            <div class="form-check">
                                <input class="form-check-input" type="checkbox" id="chkRemember">
                                <label class="form-check-label small text-muted" for="chkRemember">Remember me</label>
                            </div>
                        </div>

                        <asp:Button ID="btnLogin" runat="server" Text="Sign In to Account" CssClass="btn btn-primary-custom w-100 py-2 mb-3 fs-5" OnClick="btnLogin_Click" />

                        <div class="text-center my-3 text-muted position-relative">
                            <hr />
                            <span class="bg-white px-3 position-absolute top-50 start-50 translate-middle small text-uppercase">Or</span>
                        </div>

                        <!-- Guest Option per specification -->
                        <div class="mb-4">
                            <asp:Button ID="btnGuestLogin" runat="server" Text="Continue as Guest Passenger" 
                                        CssClass="btn btn-outline-warning text-dark w-100 py-2 fw-semibold" 
                                        CausesValidation="false" OnClick="btnGuestLogin_Click" />
                            <div class="text-center mt-1">
                                <small class="text-muted"><i class="fa-solid fa-circle-info me-1"></i>Guest mode allows flight availability checks only</small>
                            </div>
                        </div>


                        <div class="text-center mt-4">
                            <p class="mb-0 text-muted">
                                Don't have a profile yet? 
                                <a href="<%= ResolveUrl("~/Public/Register.aspx") %>" class="text-primary fw-bold text-decoration-none">Register here</a>
                            </p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>


