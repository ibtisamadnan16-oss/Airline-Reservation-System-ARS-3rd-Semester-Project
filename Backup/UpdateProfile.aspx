<%@ Page Title="Update Profile - Airline Reservation System" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeFile="UpdateProfile.aspx.cs" Inherits="UpdateProfile" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container py-4">
        <div class="row justify-content-center">
            <div class="col-lg-8">
                <!-- Navigation Breadcrumb -->
                <nav aria-label="breadcrumb" class="mb-3">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item"><a href="Default.aspx">Home</a></li>
                        <li class="breadcrumb-item"><a href="Dashboard.aspx">Dashboard</a></li>
                        <li class="breadcrumb-item"><a href="Profile.aspx">User Profile</a></li>
                        <li class="breadcrumb-item active" aria-current="page">Update Profile</li>
                    </ol>
                </nav>

                <div class="ars-card">
                    <div class="card-header-custom py-3 px-4 d-flex justify-content-between align-items-center">
                        <div>
                            <h4 class="fw-bold mb-0"><i class="fa-solid fa-user-pen me-2"></i>Update User Profile</h4>
                            <p class="small mb-0 text-white-50">Modify your personal and contact details</p>
                        </div>
                        <span class="badge bg-light text-dark"><i class="fa-solid fa-shield-halved me-1"></i>Secure Profile</span>
                    </div>

                    <div class="p-4 p-md-5">
                        <!-- Alert Banner -->
                        <asp:Panel ID="pnlAlert" runat="server" Visible="false" CssClass="alert alert-danger mb-4">
                            <i class="fa-solid fa-circle-exclamation me-2"></i>
                            <asp:Literal ID="litAlertMsg" runat="server"></asp:Literal>
                        </asp:Panel>

                        <!-- Form -->
                        <div class="row g-3">
                            <!-- Immutable System Identifiers -->
                            <div class="col-12">
                                <h6 class="text-uppercase text-secondary fw-bold small border-bottom pb-2 mb-3">
                                    <i class="fa-solid fa-id-badge me-1"></i> 1. Account Identifiers
                                </h6>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label fw-semibold">User ID / Username</label>
                                <asp:TextBox ID="txtUsername" runat="server" CssClass="form-control bg-light" ReadOnly="true" />
                                <small class="text-muted">Primary account key cannot be changed.</small>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label fw-semibold">Current Sky Miles</label>
                                <div class="input-group">
                                    <span class="input-group-text bg-warning-subtle text-warning border-warning"><i class="fa-solid fa-award"></i></span>
                                    <asp:TextBox ID="txtSkyMiles" runat="server" CssClass="form-control bg-light fw-bold" ReadOnly="true" />
                                </div>
                                <small class="text-muted">Frequent flyer miles update automatically upon flying.</small>
                            </div>

                            <!-- Personal Details -->
                            <div class="col-12 mt-4">
                                <h6 class="text-uppercase text-secondary fw-bold small border-bottom pb-2 mb-3">
                                    <i class="fa-solid fa-user me-1"></i> 2. Personal Information
                                </h6>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label fw-semibold">First Name <span class="text-danger">*</span></label>
                                <asp:TextBox ID="txtFirstName" runat="server" CssClass="form-control" />
                                <asp:RequiredFieldValidator ID="rfvFirstName" runat="server" ControlToValidate="txtFirstName"
                                    ErrorMessage="First name is required." CssClass="text-danger small" Display="Dynamic" />
                            </div>

                            <div class="col-md-6">
                                <label class="form-label fw-semibold">Last Name <span class="text-danger">*</span></label>
                                <asp:TextBox ID="txtLastName" runat="server" CssClass="form-control" />
                                <asp:RequiredFieldValidator ID="rfvLastName" runat="server" ControlToValidate="txtLastName"
                                    ErrorMessage="Last name is required." CssClass="text-danger small" Display="Dynamic" />
                            </div>

                            <div class="col-md-6">
                                <label class="form-label fw-semibold">Gender / Sex <span class="text-danger">*</span></label>
                                <asp:DropDownList ID="ddlGender" runat="server" CssClass="form-select">
                                    <asp:ListItem Value="Male" Text="Male" />
                                    <asp:ListItem Value="Female" Text="Female" />
                                    <asp:ListItem Value="Other" Text="Other" />
                                </asp:DropDownList>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label fw-semibold">Age <span class="text-danger">*</span></label>
                                <asp:TextBox ID="txtAge" runat="server" CssClass="form-control" TextMode="Number" />
                                <asp:RequiredFieldValidator ID="rfvAge" runat="server" ControlToValidate="txtAge"
                                    ErrorMessage="Age is required." CssClass="text-danger small" Display="Dynamic" />
                            </div>

                            <!-- Contact Details -->
                            <div class="col-12 mt-4">
                                <h6 class="text-uppercase text-secondary fw-bold small border-bottom pb-2 mb-3">
                                    <i class="fa-solid fa-envelope me-1"></i> 3. Contact &amp; Payment Details
                                </h6>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label fw-semibold">Email Address <span class="text-danger">*</span></label>
                                <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" TextMode="Email" />
                                <asp:RequiredFieldValidator ID="rfvEmail" runat="server" ControlToValidate="txtEmail"
                                    ErrorMessage="Email is required." CssClass="text-danger small" Display="Dynamic" />
                            </div>

                            <div class="col-md-6">
                                <label class="form-label fw-semibold">Phone Number <span class="text-danger">*</span></label>
                                <asp:TextBox ID="txtPhone" runat="server" CssClass="form-control" />
                                <asp:RequiredFieldValidator ID="rfvPhone" runat="server" ControlToValidate="txtPhone"
                                    ErrorMessage="Phone number is required." CssClass="text-danger small" Display="Dynamic" />
                            </div>

                            <div class="col-12">
                                <label class="form-label fw-semibold">Residential / Street Address <span class="text-danger">*</span></label>
                                <asp:TextBox ID="txtAddress" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="2" />
                                <asp:RequiredFieldValidator ID="rfvAddress" runat="server" ControlToValidate="txtAddress"
                                    ErrorMessage="Address is required." CssClass="text-danger small" Display="Dynamic" />
                            </div>

                            <div class="col-12">
                                <label class="form-label fw-semibold">Preferred Credit Card Number</label>
                                <asp:TextBox ID="txtCreditCard" runat="server" CssClass="form-control" placeholder="16-digit card number" />
                                <small class="text-muted">Used for 1-click ticket booking and seat blocking reservations.</small>
                            </div>

                            <!-- Security / Change Password Section -->
                            <div class="col-12 mt-4">
                                <div class="card bg-light border p-3">
                                    <h6 class="fw-bold mb-2 text-dark"><i class="fa-solid fa-lock text-primary me-1"></i> Change Password (Optional)</h6>
                                    <p class="small text-muted mb-3">Leave blank if you do not want to change your existing password.</p>
                                    
                                    <div class="row g-3">
                                        <div class="col-md-6">
                                            <label class="form-label small fw-semibold">New Password</label>
                                            <asp:TextBox ID="txtNewPassword" runat="server" CssClass="form-control" TextMode="Password" placeholder="New password" />
                                        </div>
                                        <div class="col-md-6">
                                            <label class="form-label small fw-semibold">Confirm New Password</label>
                                            <asp:TextBox ID="txtConfirmPassword" runat="server" CssClass="form-control" TextMode="Password" placeholder="Confirm password" />
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <hr class="my-4" />

                        <div class="d-flex justify-content-between align-items-center">
                            <a href="Profile.aspx" class="btn btn-outline-secondary px-4">
                                <i class="fa-solid fa-xmark me-1"></i> Cancel
                            </a>
                            <asp:Button ID="btnSaveProfile" runat="server" Text="Save Changes" 
                                CssClass="btn btn-primary-custom px-4 py-2 fs-5" OnClick="btnSaveProfile_Click" />
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
