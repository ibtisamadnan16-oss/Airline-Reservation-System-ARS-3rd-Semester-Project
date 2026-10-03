using System;
using System.Data.SqlClient;
using System.Web.UI;
using AirlineReservationSystem;

public partial class Public_Register : Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            if (UserStateHelper.IsLoggedIn)
            {
                Response.Redirect("~/User/Dashboard.aspx");
            }
        }
    }

    protected void btnRegister_Click(object sender, EventArgs e)
    {
        string username = txtUsername.Text.Trim();
        string password = txtPassword.Text.Trim();
        string firstName = txtFirstName.Text.Trim();
        string lastName = txtLastName.Text.Trim();
        string email = txtEmail.Text.Trim();
        string phone = txtPhone.Text.Trim();
        string gender = ddlGender.SelectedValue;
        string address = txtAddress.Text.Trim();
        string creditCard = txtCreditCard.Text.Trim();

        int age;
        if (!int.TryParse(txtAge.Text.Trim(), out age) || age < 1 || age > 120)
        {
            ShowError("Please enter a valid age.");
            return;
        }

        try
        {
            // 1. Check if username or email already exists in DB-User
            string checkQuery = "SELECT COUNT(*) FROM Users WHERE Username = @Username OR Email = @Email";
            SqlParameter[] checkParams = new SqlParameter[]
            {
                new SqlParameter("@Username", username),
                new SqlParameter("@Email", email)
            };

            int count = Convert.ToInt32(DbHelper.ExecuteScalar(checkQuery, checkParams));
            if (count > 0)
            {
                ShowError("A user with this User ID or Email already exists. Please choose a different one.");
                return;
            }

            // 2. Insert new user profile with SkyMiles initialized to 0
            string insertQuery = @"
                INSERT INTO Users (Username, Password, FirstName, LastName, Email, PhoneNumber, Gender, Age, Address, PreferredCreditCard, SkyMiles, Role)
                VALUES (@Username, @Password, @FirstName, @LastName, @Email, @Phone, @Gender, @Age, @Address, @CreditCard, 0, 'User')";

            SqlParameter[] insertParams = new SqlParameter[]
            {
                new SqlParameter("@Username", username),
                new SqlParameter("@Password", password),
                new SqlParameter("@FirstName", firstName),
                new SqlParameter("@LastName", lastName),
                new SqlParameter("@Email", email),
                new SqlParameter("@Phone", phone),
                new SqlParameter("@Gender", gender),
                new SqlParameter("@Age", age),
                new SqlParameter("@Address", address),
                new SqlParameter("@CreditCard", string.IsNullOrEmpty(creditCard) ? (object)DBNull.Value : creditCard)
            };

            DbHelper.ExecuteNonQuery(insertQuery, insertParams);

            // Redirect to login with success message
            Response.Redirect("~/Public/Login.aspx?msg=registered");
        }
        catch (Exception ex)
        {
            ShowError("Error creating user profile: " + ex.Message);
        }
    }

    private void ShowError(string message)
    {
        pnlAlert.Visible = true;
        pnlAlert.CssClass = "alert alert-danger mb-4";
        litAlertMsg.Text = message;
    }
}

