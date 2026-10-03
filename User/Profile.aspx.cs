using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using AirlineReservationSystem;

public partial class UserProfile : Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!UserStateHelper.IsLoggedIn)
        {
            Response.Redirect("~/Public/Login.aspx?msg=auth_required");
            return;
        }

        if (!IsPostBack)
        {
            if (Request.QueryString["msg"] == "updated")
            {
                ShowSuccessNotice("Your profile details have been successfully updated! Per Section 3.2, you can modify your profile anytime.");
            }

            LoadProfileData();

            if (Request.QueryString["mode"] == "edit")
            {
                SwitchToEditMode();
            }
        }
    }

    private void LoadProfileData()
    {
        int userId = UserStateHelper.CurrentUserId;
        try
        {
            string query = @"
                SELECT UserId, Username, FirstName, LastName, Email, PhoneNumber, Gender, Age, Address, PreferredCreditCard, SkyMiles, Role, CreatedAt
                FROM Users
                WHERE UserId = @UserId";

            SqlParameter[] parameters = new SqlParameter[]
            {
                new SqlParameter("@UserId", userId)
            };

            DataTable dt = DbHelper.ExecuteQuery(query, parameters);
            if (dt.Rows.Count > 0)
            {
                DataRow r = dt.Rows[0];
                string fname = r["FirstName"].ToString();
                string lname = r["LastName"].ToString();
                string fullName = fname + " " + lname;
                string username = r["Username"].ToString();
                string email = r["Email"].ToString();
                string phone = r["PhoneNumber"].ToString();
                string address = r["Address"].ToString();
                string gender = r["Gender"].ToString();
                string age = r["Age"].ToString();
                string role = r["Role"].ToString();
                string skyMiles = r["SkyMiles"].ToString();
                string card = r["PreferredCreditCard"] != DBNull.Value ? r["PreferredCreditCard"].ToString() : "";
                string memberSince = r["CreatedAt"] != DBNull.Value ? Convert.ToDateTime(r["CreatedAt"]).ToString("dd MMM yyyy") : "N/A";

                litHeaderFullName.Text = Server.HtmlEncode(fullName);
                litHeaderUsername.Text = Server.HtmlEncode(username);
                litHeaderCreatedAt.Text = memberSince;
                litHeaderSkyMiles.Text = skyMiles;

                litFirstName.Text = Server.HtmlEncode(fname);
                litLastName.Text = Server.HtmlEncode(lname);
                litGender.Text = Server.HtmlEncode(gender);
                litAge.Text = Server.HtmlEncode(age);
                litRole.Text = Server.HtmlEncode(role);

                litEmail.Text = Server.HtmlEncode(email);
                litPhone.Text = Server.HtmlEncode(phone);
                litAddress.Text = Server.HtmlEncode(address);

                litSkyMiles.Text = skyMiles;
                litCreditCard.Text = string.IsNullOrEmpty(card) ? "No Card Registered" : Server.HtmlEncode(card);

                txtEditUsername.Text = username;
                txtEditSkyMiles.Text = skyMiles + " Miles";
                txtEditFirstName.Text = fname;
                txtEditLastName.Text = lname;
                txtEditEmail.Text = email;
                txtEditPhone.Text = phone;
                txtEditAddress.Text = address;
                txtEditAge.Text = age;
                txtEditCreditCard.Text = card;

                if (ddlEditGender.Items.FindByValue(gender) != null)
                {
                    ddlEditGender.SelectedValue = gender;
                }
            }
        }
        catch (Exception ex)
        {
            ShowErrorNotice("Error loading profile: " + ex.Message);
        }
    }

    protected void btnToggleEditMode_Click(object sender, EventArgs e)
    {
        SwitchToEditMode();
    }

    protected void btnCancelEdit_Click(object sender, EventArgs e)
    {
        SwitchToViewMode();
        pnlNotice.Visible = false;
    }

    private void SwitchToEditMode()
    {
        pnlViewProfile.Visible = false;
        pnlEditProfile.Visible = true;
        btnToggleEditMode.Visible = false;
    }

    private void SwitchToViewMode()
    {
        pnlViewProfile.Visible = true;
        pnlEditProfile.Visible = false;
        btnToggleEditMode.Visible = true;
    }

    protected void btnSaveProfile_Click(object sender, EventArgs e)
    {
        int userId = UserStateHelper.CurrentUserId;
        string firstName = txtEditFirstName.Text.Trim();
        string lastName = txtEditLastName.Text.Trim();
        string email = txtEditEmail.Text.Trim();
        string phone = txtEditPhone.Text.Trim();
        string gender = ddlEditGender.SelectedValue;
        string address = txtEditAddress.Text.Trim();
        string creditCard = txtEditCreditCard.Text.Trim();
        string newPass = txtEditNewPassword.Text.Trim();
        string confPass = txtEditConfirmPassword.Text.Trim();

        int age;
        if (!int.TryParse(txtEditAge.Text.Trim(), out age) || age < 1 || age > 120)
        {
            ShowErrorNotice("Please enter a valid age between 1 and 120.");
            return;
        }

        if (string.IsNullOrWhiteSpace(address))
        {
            ShowErrorNotice("Residential address cannot be blank.");
            return;
        }

        if (string.IsNullOrWhiteSpace(phone))
        {
            ShowErrorNotice("Phone number cannot be blank.");
            return;
        }

        bool changePassword = false;
        if (!string.IsNullOrEmpty(newPass) || !string.IsNullOrEmpty(confPass))
        {
            if (newPass.Length < 6)
            {
                ShowErrorNotice("New password must be at least 6 characters long.");
                return;
            }
            if (newPass != confPass)
            {
                ShowErrorNotice("New password and confirm password do not match.");
                return;
            }
            changePassword = true;
        }

        try
        {
            string emailCheckQuery = "SELECT COUNT(*) FROM Users WHERE Email = @Email AND UserId != @UserId";
            SqlParameter[] emailParams = new SqlParameter[]
            {
                new SqlParameter("@Email", email),
                new SqlParameter("@UserId", userId)
            };

            int emailCount = Convert.ToInt32(DbHelper.ExecuteScalar(emailCheckQuery, emailParams));
            if (emailCount > 0)
            {
                ShowErrorNotice("This email address is already registered to another user account.");
                return;
            }

            string updateQuery;
            SqlParameter[] updateParams;

            if (changePassword)
            {
                updateQuery = @"
                    UPDATE Users
                    SET FirstName = @FirstName,
                        LastName = @LastName,
                        Email = @Email,
                        PhoneNumber = @Phone,
                        Gender = @Gender,
                        Age = @Age,
                        Address = @Address,
                        PreferredCreditCard = @CreditCard,
                        Password = @Password
                    WHERE UserId = @UserId";

                updateParams = new SqlParameter[]
                {
                    new SqlParameter("@FirstName", firstName),
                    new SqlParameter("@LastName", lastName),
                    new SqlParameter("@Email", email),
                    new SqlParameter("@Phone", phone),
                    new SqlParameter("@Gender", gender),
                    new SqlParameter("@Age", age),
                    new SqlParameter("@Address", address),
                    new SqlParameter("@CreditCard", string.IsNullOrEmpty(creditCard) ? (object)DBNull.Value : creditCard),
                    new SqlParameter("@Password", newPass),
                    new SqlParameter("@UserId", userId)
                };
            }
            else
            {
                updateQuery = @"
                    UPDATE Users
                    SET FirstName = @FirstName,
                        LastName = @LastName,
                        Email = @Email,
                        PhoneNumber = @Phone,
                        Gender = @Gender,
                        Age = @Age,
                        Address = @Address,
                        PreferredCreditCard = @CreditCard
                    WHERE UserId = @UserId";

                updateParams = new SqlParameter[]
                {
                    new SqlParameter("@FirstName", firstName),
                    new SqlParameter("@LastName", lastName),
                    new SqlParameter("@Email", email),
                    new SqlParameter("@Phone", phone),
                    new SqlParameter("@Gender", gender),
                    new SqlParameter("@Age", age),
                    new SqlParameter("@Address", address),
                    new SqlParameter("@CreditCard", string.IsNullOrEmpty(creditCard) ? (object)DBNull.Value : creditCard),
                    new SqlParameter("@UserId", userId)
                };
            }

            DbHelper.ExecuteNonQuery(updateQuery, updateParams);

            Session["FullName"] = firstName + " " + lastName;

            LoadProfileData();
            SwitchToViewMode();

            ShowSuccessNotice("Your profile information has been successfully updated! Per Section 3.2, you can update your profile anytime.");
        }
        catch (Exception ex)
        {
            ShowErrorNotice("Failed to update profile: " + ex.Message);
        }
    }

    private void ShowSuccessNotice(string msg)
    {
        pnlNotice.Visible = true;
        pnlNotice.CssClass = "alert alert-success alert-dismissible fade show";
        litNotice.Text = string.Format("<i class='fa-solid fa-circle-check me-2'></i> {0}", msg);
    }

    private void ShowErrorNotice(string msg)
    {
        pnlNotice.Visible = true;
        pnlNotice.CssClass = "alert alert-danger alert-dismissible fade show";
        litNotice.Text = string.Format("<i class='fa-solid fa-circle-exclamation me-2'></i> {0}", msg);
    }
}

