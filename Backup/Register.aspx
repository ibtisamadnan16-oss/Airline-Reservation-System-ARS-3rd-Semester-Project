<%@ Page Title="Register User Profile - Airline Reservation System" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeFile="Register.aspx.cs" Inherits="Register" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container py-5">
        <div class="row justify-content-center">
            <div class="col-lg-8">
                <div class="ars-card">
                    <div class="card-header-custom py-3 px-4">
                        <div class="d-flex align-items-center justify-content-between">
                            <div>
                                <h3 class="fw-bold mb-0"><i class="fa-solid fa-user-plus me-2"></i>Passenger Registration</h3>
                                <p class="small mb-0 text-white-50">Create your AeroFly passenger profile</p>
                            </div>
                            <span class="badge bg-warning text-dark"><i class="fa-solid fa-award me-1"></i>+0 SkyMiles Initialized</span>
                        </div>
                    </div>

                    <div class="p-4 p-md-5">
                        <asp:Panel ID="pnlAlert" runat="server" Visible="false" CssClass="alert alert-danger mb-4">
                            <i class="fa-solid fa-circle-exclamation me-2"></i>
                            <asp:Literal ID="litAlertMsg" runat="server"></asp:Literal>
                        </asp:Panel>

                        <div class="alert alert-info py-2 small mb-4">
                            <i class="fa-solid fa-circle-info me-1"></i>
                            Registered users can block seats, buy tickets, confirm, reschedule, and cancel reservations. All fields marked with <span class="text-danger">*</span> are required.
                        </div>

                        <!-- Registration Form -->
                        <div class="row g-3">
                            <!-- Account Credentials -->
                            <div class="col-12">
                                <h6 class="text-uppercase text-secondary fw-bold small border-bottom pb-2 mb-3">
                                    <i class="fa-solid fa-key me-1"></i> 1. Account Credentials
                                </h6>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label fw-semibold">User ID / Username <span class="text-danger">*</span></label>
                                <asp:TextBox ID="txtUsername" runat="server" CssClass="form-control" placeholder="Unique username" />
                                <asp:RequiredFieldValidator ID="rfvUsername" runat="server" ControlToValidate="txtUsername"
                                    ErrorMessage="User ID is required." CssClass="text-danger small" Display="Dynamic" />
                            </div>

                            <div class="col-md-6">
                                <label class="form-label fw-semibold">Password <span class="text-danger">*</span></label>
                                <asp:TextBox ID="txtPassword" runat="server" CssClass="form-control" TextMode="Password" placeholder="Minimum 6 characters" />
                                <asp:RequiredFieldValidator ID="rfvPassword" runat="server" ControlToValidate="txtPassword"
                                    ErrorMessage="Password is required." CssClass="text-danger small" Display="Dynamic" />
                            </div>

                            <!-- Personal Information -->
                            <div class="col-12 mt-4">
                                <h6 class="text-uppercase text-secondary fw-bold small border-bottom pb-2 mb-3">
                                    <i class="fa-solid fa-address-card me-1"></i> 2. Personal Information
                                </h6>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label fw-semibold">First Name <span class="text-danger">*</span></label>
                                <asp:TextBox ID="txtFirstName" runat="server" CssClass="form-control" placeholder="e.g. Ali" />
                                <asp:RequiredFieldValidator ID="rfvFirstName" runat="server" ControlToValidate="txtFirstName"
                                    ErrorMessage="First name is required." CssClass="text-danger small" Display="Dynamic" />
                            </div>

                            <div class="col-md-6">
                                <label class="form-label fw-semibold">Last Name <span class="text-danger">*</span></label>
                                <asp:TextBox ID="txtLastName" runat="server" CssClass="form-control" placeholder="e.g. Khan" />
                                <asp:RequiredFieldValidator ID="rfvLastName" runat="server" ControlToValidate="txtLastName"
                                    ErrorMessage="Last name is required." CssClass="text-danger small" Display="Dynamic" />
                            </div>

                            <div class="col-md-6">
                                <label class="form-label fw-semibold">Email Address <span class="text-danger">*</span></label>
                                <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" TextMode="Email" placeholder="ali.khan@example.com" />
                                <asp:RequiredFieldValidator ID="rfvEmail" runat="server" ControlToValidate="txtEmail"
                                    ErrorMessage="Email address is required." CssClass="text-danger small" Display="Dynamic" />
                            </div>

                            <div class="col-md-6">
                                <label class="form-label fw-semibold">Phone Number <span class="text-danger">*</span></label>
                                <asp:TextBox ID="txtPhone" runat="server" CssClass="form-control" placeholder="+92 300 1234567" />
                                <asp:RequiredFieldValidator ID="rfvPhone" runat="server" ControlToValidate="txtPhone"
                                    ErrorMessage="Phone number is required." CssClass="text-danger small" Display="Dynamic" />
                            </div>

                            <div class="col-md-4">
                                <label class="form-label fw-semibold">Gender / Sex <span class="text-danger">*</span></label>
                                <asp:DropDownList ID="ddlGender" runat="server" CssClass="form-select">
                                    <asp:ListItem Value="Male" Text="Male" />
                                    <asp:ListItem Value="Female" Text="Female" />
                                    <asp:ListItem Value="Other" Text="Other" />
                                </asp:DropDownList>
                            </div>

                            <div class="col-md-4">
                                <label class="form-label fw-semibold">Age <span class="text-danger">*</span></label>
                                <asp:TextBox ID="txtAge" runat="server" CssClass="form-control" TextMode="Number" placeholder="e.g. 25" />
                                <asp:RequiredFieldValidator ID="rfvAge" runat="server" ControlToValidate="txtAge"
                                    ErrorMessage="Age is required." CssClass="text-danger small" Display="Dynamic" />
                            </div>

                            <div class="col-md-4">
                                <label class="form-label fw-semibold">Initial SkyMiles</label>
                                <input type="text" class="form-control bg-light" value="0 (Auto-Initialized)" readonly disabled />
                            </div>

                            <div class="col-12">
                                <label class="form-label fw-semibold">Residential / Contact Address <span class="text-danger">*</span></label>
                                <asp:TextBox ID="txtAddress" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="2" placeholder="Full postal street address" />
                                <asp:RequiredFieldValidator ID="rfvAddress" runat="server" ControlToValidate="txtAddress"
                                    ErrorMessage="Address is required." CssClass="text-danger small" Display="Dynamic" />
                            </div>

                            <!-- Payment Information -->
                            <div class="col-12 mt-4">
                                <h6 class="text-uppercase text-secondary fw-bold small border-bottom pb-2 mb-3">
                                    <i class="fa-solid fa-credit-card me-1"></i> 3. Preferred Payment (Section 3.2)
                                </h6>
                            </div>

                            <div class="col-12">
                                <label class="form-label fw-semibold">Preferred Credit Card Number</label>
                                <asp:TextBox ID="txtCreditCard" runat="server" CssClass="form-control" placeholder="16-digit Card Number for fast flight bookings" />
                                <small class="text-muted">Stored securely for one-click ticket purchases and reservation deposits.</small>
                            </div>
                        </div>

                        <hr class="my-4" />

                        <div class="d-flex justify-content-between align-items-center">
                            <a href="Login.aspx" class="text-decoration-none">
                                <i class="fa-solid fa-arrow-left me-1"></i> Already registered? Sign in
                            </a>
                            <asp:Button ID="btnRegister" runat="server" Text="Create Profile &amp; Register" 
                                CssClass="btn btn-primary-custom px-4 py-2 fs-5" OnClick="btnRegister_Click" />
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
