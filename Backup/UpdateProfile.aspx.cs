using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using AirlineReservationSystem;

public partial class UpdateProfile : Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!UserStateHelper.IsLoggedIn)
        {
            Response.Redirect("~/Login.aspx?msg=auth_required");
            return;
        }

        if (!IsPostBack)
        {
            LoadUserData();
        }
    }

    private void LoadUserData()
    {
        int userId = UserStateHelper.CurrentUserId;
        try
        {
            string query = "SELECT Username, FirstName, LastName, Email, PhoneNumber, Gender, Age, Address, PreferredCreditCard, SkyMiles FROM Users WHERE UserId = @UserId";
            SqlParameter[] parameters = new SqlParameter[]
            {
                new SqlParameter("@UserId", userId)
            };

            DataTable dt = DbHelper.ExecuteQuery(query, parameters);
            if (dt.Rows.Count > 0)
            {
                DataRow r = dt.Rows[0];
                txtUsername.Text = r["Username"].ToString();
                txtSkyMiles.Text = r["SkyMiles"].ToString() + " Miles";
                txtFirstName.Text = r["FirstName"].ToString();
                txtLastName.Text = r["LastName"].ToString();
                txtEmail.Text = r["Email"].ToString();
                txtPhone.Text = r["PhoneNumber"].ToString();
                txtAddress.Text = r["Address"].ToString();
                txtAge.Text = r["Age"].ToString();
                txtCreditCard.Text = r["PreferredCreditCard"].ToString();

                string gender = r["Gender"].ToString();
                if (ddlGender.Items.FindByValue(gender) != null)
                {
                    ddlGender.SelectedValue = gender;
                }
            }
        }
        catch (Exception ex)
        {
            ShowError("Failed to load user information: " + ex.Message);
        }
    }

    protected void btnSaveProfile_Click(object sender, EventArgs e)
    {
        int userId = UserStateHelper.CurrentUserId;
        string firstName = txtFirstName.Text.Trim();
        string lastName = txtLastName.Text.Trim();
        string email = txtEmail.Text.Trim();
        string phone = txtPhone.Text.Trim();
        string gender = ddlGender.SelectedValue;
        string address = txtAddress.Text.Trim();
        string creditCard = txtCreditCard.Text.Trim();
        string newPass = txtNewPassword.Text.Trim();
        string confPass = txtConfirmPassword.Text.Trim();

        int age;
        if (!int.TryParse(txtAge.Text.Trim(), out age) || age < 1 || age > 120)
        {
            ShowError("Please enter a valid age between 1 and 120.");
            return;
        }

        // Validate password change if provided
        bool changePassword = false;
        if (!string.IsNullOrEmpty(newPass) || !string.IsNullOrEmpty(confPass))
        {
            if (newPass.Length < 6)
            {
                ShowError("New password must be at least 6 characters long.");
                return;
            }
            if (newPass != confPass)
            {
                ShowError("New password and confirm password do not match.");
                return;
            }
            changePassword = true;
        }

        try
        {
            // Check if email changed and taken by another user
            string emailCheckQuery = "SELECT COUNT(*) FROM Users WHERE Email = @Email AND UserId != @UserId";
            SqlParameter[] emailParams = new SqlParameter[]
            {
                new SqlParameter("@Email", email),
                new SqlParameter("@UserId", userId)
            };

            int emailCount = Convert.ToInt32(DbHelper.ExecuteScalar(emailCheckQuery, emailParams));
            if (emailCount > 0)
            {
                ShowError("This email address is already registered to another user account.");
                return;
            }

            // Perform Update
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

            // Update session values
            Session["FullName"] = firstName + " " + lastName;

            Response.Redirect("~/Profile.aspx?msg=updated");
        }
        catch (Exception ex)
        {
            ShowError("Failed to update profile: " + ex.Message);
        }
    }

    private void ShowError(string msg)
    {
        pnlAlert.Visible = true;
        litAlertMsg.Text = msg;
    }
}
