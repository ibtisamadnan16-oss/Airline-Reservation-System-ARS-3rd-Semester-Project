<%@ Page Title="My Profile - AeroFly Airline Reservation System" Language="C#" MasterPageFile="~/Shared/Site.Master" AutoEventWireup="true" CodeFile="Profile.aspx.cs" Inherits="UserProfile" EnableEventValidation="false" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .profile-nav-tab {
            font-weight: 600;
            padding: 0.75rem 1.25rem;
            border-radius: 0.5rem 0.5rem 0 0;
            cursor: pointer;
            transition: all 0.2s ease;
        }
        .profile-nav-tab.active {
            background-color: #ffffff;
            color: #0d6efd !important;
            border-bottom: 3px solid #0d6efd;
        }
        .quick-edit-link {
            font-size: 0.8rem;
            text-decoration: none;
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container py-4">
        <div class="row justify-content-center">
            <div class="col-lg-10">
                <nav aria-label="breadcrumb" class="mb-3">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item"><a href="Default.aspx">Home</a></li>
                        <li class="breadcrumb-item"><a href="<%= ResolveUrl("~/User/Dashboard.aspx") %>">Dashboard</a></li>
                        <li class="breadcrumb-item active" aria-current="page">My Profile</li>
                    </ol>
                </nav>

                <asp:Panel ID="pnlNotice" runat="server" Visible="false" CssClass="alert alert-success alert-dismissible fade show" role="alert">
                    <asp:Literal ID="litNotice" runat="server"></asp:Literal>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </asp:Panel>

                <div class="ars-card mb-4 bg-white border-0 shadow-sm p-4 border-start border-primary border-4">
                    <div class="d-flex flex-column flex-md-row align-items-md-center justify-content-between gap-3">
                        <div class="d-flex align-items-center">
                            <div class="bg-primary text-white rounded-circle p-3 me-3 d-flex align-items-center justify-content-center shadow-sm" style="width: 75px; height: 75px;">
                                <i class="fa-solid fa-user-gear fa-2x"></i>
                            </div>
                            <div>
                                <div class="d-flex align-items-center gap-2 flex-wrap">
                                    <h3 class="fw-bold mb-0 text-dark"><asp:Literal ID="litHeaderFullName" runat="server"></asp:Literal></h3>
                                    <span class="badge bg-success-subtle text-success border border-success px-2 py-1"><i class="fa-solid fa-circle-check me-1"></i> Verified Member</span>
                                </div>
                                <p class="text-muted mb-0 small mt-1">
                                    <span class="badge bg-primary-subtle text-primary me-2"><i class="fa-solid fa-id-card me-1"></i> User ID: <strong><asp:Literal ID="litHeaderUsername" runat="server"></asp:Literal></strong></span>
                                    <span class="badge bg-secondary-subtle text-secondary me-2"><i class="fa-solid fa-calendar me-1"></i> Member Since: <asp:Literal ID="litHeaderCreatedAt" runat="server"></asp:Literal></span>
                                    <span class="badge bg-warning-subtle text-dark border border-warning"><i class="fa-solid fa-award text-warning me-1"></i> <asp:Literal ID="litHeaderSkyMiles" runat="server"></asp:Literal> SkyMiles</span>
                                </p>
                            </div>
                        </div>
                        <div class="text-md-end d-flex flex-column flex-sm-row gap-2">
                            <asp:LinkButton ID="btnToggleEditMode" runat="server" CssClass="btn btn-primary fw-bold px-3" OnClick="btnToggleEditMode_Click">
                                <i class="fa-solid fa-user-pen me-1"></i> Edit My Profile
                            </asp:LinkButton>
                            <a href="<%= ResolveUrl("~/User/Dashboard.aspx") %>" class="btn btn-outline-secondary">
                                <i class="fa-solid fa-gauge-high me-1"></i> Dashboard
                            </a>
                        </div>
                    </div>

                    <div class="alert alert-info border-info mt-3 mb-0 py-2 px-3 small d-flex align-items-center">
                        <i class="fa-solid fa-circle-info fa-lg me-2 text-info"></i>
                        <div>
                            <strong>Phase 10 Specification:</strong> Registered users can update their profile information (Address, Phone, Preferred Credit Card, and other profile details) at any time.
                        </div>
                    </div>
                </div>

                <asp:Panel ID="pnlViewProfile" runat="server" Visible="true">
                    <div class="row g-4">
                        <div class="col-md-6">
                            <div class="ars-card h-100 shadow-sm border-0">
                                <div class="card-header-custom d-flex justify-content-between align-items-center">
                                    <span><i class="fa-solid fa-user me-2"></i> 1. Personal Information</span>
                                    <asp:LinkButton ID="btnEditPersonal" runat="server" CssClass="text-white small text-decoration-none" OnClick="btnToggleEditMode_Click">
                                        <i class="fa-solid fa-pen-to-square me-1"></i> Edit
                                    </asp:LinkButton>
                                </div>
                                <div class="p-4 bg-white">
                                    <ul class="list-group list-group-flush">
                                        <li class="list-group-item d-flex justify-content-between align-items-center px-0">
                                            <span class="text-muted"><i class="fa-solid fa-user-tag me-2 text-primary"></i> First Name</span>
                                            <span class="fw-bold text-dark"><asp:Literal ID="litFirstName" runat="server"></asp:Literal></span>
                                        </li>
                                        <li class="list-group-item d-flex justify-content-between align-items-center px-0">
                                            <span class="text-muted"><i class="fa-solid fa-user-tag me-2 text-primary"></i> Last Name</span>
                                            <span class="fw-bold text-dark"><asp:Literal ID="litLastName" runat="server"></asp:Literal></span>
                                        </li>
                                        <li class="list-group-item d-flex justify-content-between align-items-center px-0">
                                            <span class="text-muted"><i class="fa-solid fa-venus-mars me-2 text-primary"></i> Gender / Sex</span>
                                            <span class="fw-semibold text-dark"><asp:Literal ID="litGender" runat="server"></asp:Literal></span>
                                        </li>
                                        <li class="list-group-item d-flex justify-content-between align-items-center px-0">
                                            <span class="text-muted"><i class="fa-solid fa-cake-candles me-2 text-primary"></i> Age</span>
                                            <span class="fw-semibold text-dark"><asp:Literal ID="litAge" runat="server"></asp:Literal> years</span>
                                        </li>
                                        <li class="list-group-item d-flex justify-content-between align-items-center px-0">
                                            <span class="text-muted"><i class="fa-solid fa-shield-halved me-2 text-primary"></i> Account Role</span>
                                            <span class="badge bg-success-subtle text-success border border-success"><asp:Literal ID="litRole" runat="server"></asp:Literal></span>
                                        </li>
                                    </ul>
                                </div>
                            </div>
                        </div>

                        <div class="col-md-6">
                            <div class="ars-card h-100 shadow-sm border-0">
                                <div class="card-header-custom d-flex justify-content-between align-items-center">
                                    <span><i class="fa-solid fa-address-book me-2"></i> 2. Contact &amp; Residential Address</span>
                                    <asp:LinkButton ID="btnEditContact" runat="server" CssClass="text-white small text-decoration-none" OnClick="btnToggleEditMode_Click">
                                        <i class="fa-solid fa-pen-to-square me-1"></i> Edit
                                    </asp:LinkButton>
                                </div>
                                <div class="p-4 bg-white">
                                    <ul class="list-group list-group-flush">
                                        <li class="list-group-item d-flex justify-content-between align-items-center px-0">
                                            <span class="text-muted"><i class="fa-solid fa-envelope me-2 text-primary"></i> Email Address</span>
                                            <span class="fw-bold text-dark text-break"><asp:Literal ID="litEmail" runat="server"></asp:Literal></span>
                                        </li>
                                        <li class="list-group-item d-flex justify-content-between align-items-center px-0">
                                            <span class="text-muted"><i class="fa-solid fa-phone me-2 text-primary"></i> Phone Number</span>
                                            <span class="fw-bold text-primary font-monospace"><asp:Literal ID="litPhone" runat="server"></asp:Literal></span>
                                        </li>
                                        <li class="list-group-item px-0">
                                            <div class="d-flex justify-content-between align-items-center mb-1">
                                                <span class="text-muted"><i class="fa-solid fa-location-dot me-2 text-primary"></i> Residential Address</span>
                                                <asp:LinkButton ID="btnEditAddressLink" runat="server" CssClass="quick-edit-link text-primary" OnClick="btnToggleEditMode_Click">Change Address</asp:LinkButton>
                                            </div>
                                            <div class="fw-semibold bg-light p-3 rounded border text-dark">
                                                <i class="fa-solid fa-house-chimney text-muted me-2"></i><asp:Literal ID="litAddress" runat="server"></asp:Literal>
                                            </div>
                                        </li>
                                    </ul>
                                </div>
                            </div>
                        </div>

                        <div class="col-12">
                            <div class="ars-card shadow-sm border-0">
                                <div class="card-header-custom d-flex justify-content-between align-items-center">
                                    <span><i class="fa-solid fa-credit-card me-2"></i> 3. Preferred Payment &amp; Frequent Flyer Privileges</span>
                                    <asp:LinkButton ID="btnEditPayment" runat="server" CssClass="text-white small text-decoration-none" OnClick="btnToggleEditMode_Click">
                                        <i class="fa-solid fa-pen-to-square me-1"></i> Edit
                                    </asp:LinkButton>
                                </div>
                                <div class="p-4 bg-white">
                                    <div class="row g-4 align-items-center">
                                        <div class="col-md-6">
                                            <div class="p-3 bg-light rounded-3 border">
                                                <div class="d-flex align-items-center justify-content-between mb-2">
                                                    <span class="text-muted fw-bold small text-uppercase"><i class="fa-solid fa-credit-card text-primary me-1"></i> Preferred Credit Card</span>
                                                    <span class="badge bg-primary">Express Checkout</span>
                                                </div>
                                                <div class="fs-4 fw-bold text-dark mb-1 font-monospace">
                                                    <code><asp:Literal ID="litCreditCard" runat="server"></asp:Literal></code>
                                                </div>
                                                <small class="text-muted d-block">Used for automatic 1-click booking, seat confirmations, and refund settlements.</small>
                                                <div class="mt-2">
                                                    <asp:LinkButton ID="btnChangeCardLink" runat="server" CssClass="btn btn-outline-primary btn-sm" OnClick="btnToggleEditMode_Click">
                                                        <i class="fa-solid fa-credit-card me-1"></i> Update Credit Card
                                                    </asp:LinkButton>
                                                </div>
                                            </div>
                                        </div>

                                        <div class="col-md-6">
                                            <div class="p-3 bg-light rounded-3 border">
                                                <div class="d-flex align-items-center justify-content-between mb-2">
                                                    <span class="text-muted fw-bold small text-uppercase"><i class="fa-solid fa-award text-warning me-1"></i> Sky Miles Reward Balance</span>
                                                    <span class="badge bg-warning text-dark fw-bold">Active Member</span>
                                                </div>
                                                <div class="display-6 fw-bold text-primary mb-1">
                                                    <asp:Literal ID="litSkyMiles" runat="server"></asp:Literal>
                                                    <span class="fs-6 text-muted fw-normal">Miles Earned</span>
                                                </div>
                                                <small class="text-muted d-block">Initialized to 0 on registration. Earn +350 miles per flight purchase; -350 deducted on cancellation.</small>
                                                <div class="mt-2">
                                                    <a href="SearchFlights.aspx" class="btn btn-outline-success btn-sm">
                                                        <i class="fa-solid fa-plane me-1"></i> Book Flights to Earn Miles
                                                    </a>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </asp:Panel>

                <asp:Panel ID="pnlEditProfile" runat="server" Visible="false">
                    <div class="ars-card shadow-sm border-0">
                        <div class="card-header bg-primary text-white py-3 px-4 d-flex justify-content-between align-items-center">
                            <div>
                                <h4 class="fw-bold mb-0"><i class="fa-solid fa-user-pen me-2"></i> Update Profile Information</h4>
                                <small class="text-white-50">Modify your address, phone, credit card, and personal credentials anytime.</small>
                            </div>
                            <span class="badge bg-light text-dark"><i class="fa-solid fa-lock me-1"></i> Secure Form</span>
                        </div>

                        <div class="p-4 p-md-5 bg-white">
                            <h6 class="text-uppercase text-secondary fw-bold small border-bottom pb-2 mb-3">
                                <i class="fa-solid fa-id-badge me-1"></i> Account Keys (Permanent)
                            </h6>
                            <div class="row g-3 mb-4">
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">User ID / Username</label>
                                    <asp:TextBox ID="txtEditUsername" runat="server" CssClass="form-control bg-light fw-bold text-muted" ReadOnly="true"></asp:TextBox>
                                    <small class="text-muted">Unique account username cannot be changed.</small>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Sky Miles Balance</label>
                                    <asp:TextBox ID="txtEditSkyMiles" runat="server" CssClass="form-control bg-light fw-bold text-warning" ReadOnly="true"></asp:TextBox>
                                    <small class="text-muted">Managed automatically by flight booking transactions.</small>
                                </div>
                            </div>

                            <h6 class="text-uppercase text-secondary fw-bold small border-bottom pb-2 mb-3">
                                <i class="fa-solid fa-address-book me-1"></i> Contact &amp; Payment Preferences
                            </h6>
                            <div class="row g-3 mb-4">
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Phone Number <span class="text-danger">*</span></label>
                                    <div class="input-group">
                                        <span class="input-group-text bg-white"><i class="fa-solid fa-phone text-primary"></i></span>
                                        <asp:TextBox ID="txtEditPhone" runat="server" CssClass="form-control" placeholder="+92 300 1234567"></asp:TextBox>
                                    </div>
                                    <asp:RequiredFieldValidator ID="rfvEditPhone" runat="server" ControlToValidate="txtEditPhone"
                                        ErrorMessage="Phone number is required." CssClass="text-danger small" Display="Dynamic" ValidationGroup="ProfileUpdateGroup" />
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Email Address <span class="text-danger">*</span></label>
                                    <div class="input-group">
                                        <span class="input-group-text bg-white"><i class="fa-solid fa-envelope text-primary"></i></span>
                                        <asp:TextBox ID="txtEditEmail" runat="server" CssClass="form-control" TextMode="Email" placeholder="user@example.com"></asp:TextBox>
                                    </div>
                                    <asp:RequiredFieldValidator ID="rfvEditEmail" runat="server" ControlToValidate="txtEditEmail"
                                        ErrorMessage="Email address is required." CssClass="text-danger small" Display="Dynamic" ValidationGroup="ProfileUpdateGroup" />
                                </div>

                                <div class="col-12">
                                    <label class="form-label fw-semibold">Residential / Street Address <span class="text-danger">*</span></label>
                                    <div class="input-group">
                                        <span class="input-group-text bg-white"><i class="fa-solid fa-location-dot text-primary"></i></span>
                                        <asp:TextBox ID="txtEditAddress" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="2" placeholder="Enter complete residential address"></asp:TextBox>
                                    </div>
                                    <asp:RequiredFieldValidator ID="rfvEditAddress" runat="server" ControlToValidate="txtEditAddress"
                                        ErrorMessage="Address is required." CssClass="text-danger small" Display="Dynamic" ValidationGroup="ProfileUpdateGroup" />
                                </div>

                                <div class="col-12">
                                    <label class="form-label fw-semibold">Preferred Credit Card Number</label>
                                    <div class="input-group">
                                        <span class="input-group-text bg-white"><i class="fa-solid fa-credit-card text-primary"></i></span>
                                        <asp:TextBox ID="txtEditCreditCard" runat="server" CssClass="form-control font-monospace" placeholder="e.g. 4532-1234-5678-9012 or ************4321"></asp:TextBox>
                                    </div>
                                    <small class="text-muted">Saved securely in your profile for fast seat reservations and blocking deposits.</small>
                                </div>
                            </div>

                            <h6 class="text-uppercase text-secondary fw-bold small border-bottom pb-2 mb-3">
                                <i class="fa-solid fa-user me-1"></i> Personal Information
                            </h6>
                            <div class="row g-3 mb-4">
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">First Name <span class="text-danger">*</span></label>
                                    <asp:TextBox ID="txtEditFirstName" runat="server" CssClass="form-control"></asp:TextBox>
                                    <asp:RequiredFieldValidator ID="rfvEditFirstName" runat="server" ControlToValidate="txtEditFirstName"
                                        ErrorMessage="First name is required." CssClass="text-danger small" Display="Dynamic" ValidationGroup="ProfileUpdateGroup" />
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Last Name <span class="text-danger">*</span></label>
                                    <asp:TextBox ID="txtEditLastName" runat="server" CssClass="form-control"></asp:TextBox>
                                    <asp:RequiredFieldValidator ID="rfvEditLastName" runat="server" ControlToValidate="txtEditLastName"
                                        ErrorMessage="Last name is required." CssClass="text-danger small" Display="Dynamic" ValidationGroup="ProfileUpdateGroup" />
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Gender / Sex <span class="text-danger">*</span></label>
                                    <asp:DropDownList ID="ddlEditGender" runat="server" CssClass="form-select">
                                        <asp:ListItem Value="Male" Text="Male"></asp:ListItem>
                                        <asp:ListItem Value="Female" Text="Female"></asp:ListItem>
                                        <asp:ListItem Value="Other" Text="Other"></asp:ListItem>
                                    </asp:DropDownList>
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Age <span class="text-danger">*</span></label>
                                    <asp:TextBox ID="txtEditAge" runat="server" CssClass="form-control" TextMode="Number"></asp:TextBox>
                                    <asp:RequiredFieldValidator ID="rfvEditAge" runat="server" ControlToValidate="txtEditAge"
                                        ErrorMessage="Age is required." CssClass="text-danger small" Display="Dynamic" ValidationGroup="ProfileUpdateGroup" />
                                </div>
                            </div>

                            <h6 class="text-uppercase text-secondary fw-bold small border-bottom pb-2 mb-3">
                                <i class="fa-solid fa-lock me-1"></i> Security / Change Password (Optional)
                            </h6>
                            <div class="card bg-light border p-3 mb-4">
                                <p class="small text-muted mb-2">Leave blank if you wish to keep your existing password.</p>
                                <div class="row g-3">
                                    <div class="col-md-6">
                                        <label class="form-label small fw-semibold">New Password</label>
                                        <asp:TextBox ID="txtEditNewPassword" runat="server" CssClass="form-control" TextMode="Password" placeholder="Minimum 6 characters"></asp:TextBox>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label small fw-semibold">Confirm New Password</label>
                                        <asp:TextBox ID="txtEditConfirmPassword" runat="server" CssClass="form-control" TextMode="Password" placeholder="Repeat new password"></asp:TextBox>
                                    </div>
                                </div>
                            </div>

                            <div class="d-flex justify-content-between align-items-center">
                                <asp:Button ID="btnCancelEdit" runat="server" Text="Cancel" CssClass="btn btn-outline-secondary px-4" OnClick="btnCancelEdit_Click" CausesValidation="false" />
                                <asp:Button ID="btnSaveProfile" runat="server" Text="Save Profile Changes" CssClass="btn btn-primary btn-lg fw-bold px-4" OnClick="btnSaveProfile_Click" ValidationGroup="ProfileUpdateGroup" />
                            </div>
                        </div>
                    </div>
                </asp:Panel>
            </div>
        </div>
    </div>
</asp:Content>

