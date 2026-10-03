using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using AirlineReservationSystem;

public partial class Public_Login : Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            // If already logged in, redirect to Dashboard
            if (UserStateHelper.IsLoggedIn)
            {
                Response.Redirect("~/User/Dashboard.aspx");
            }

            if (Request.QueryString["msg"] == "registered")
            {
                pnlAlert.Visible = true;
                pnlAlert.CssClass = "alert alert-success mb-4";
                litAlertMsg.Text = "Registration successful! You can now log in with your credentials.";
            }
            else if (Request.QueryString["msg"] == "logged_out")
            {
                pnlAlert.Visible = true;
                pnlAlert.CssClass = "alert alert-info mb-4";
                litAlertMsg.Text = "You have been safely logged out.";
            }
            else if (Request.QueryString["msg"] == "auth_required")
            {
                pnlAlert.Visible = true;
                pnlAlert.CssClass = "alert alert-warning mb-4";
                litAlertMsg.Text = "Please log in with a registered account to access that page or reserve flights.";
            }
        }
    }

    protected void btnLogin_Click(object sender, EventArgs e)
    {
        string username = txtUsername.Text.Trim();
        string password = txtPassword.Text.Trim();

        if (string.IsNullOrEmpty(username) || string.IsNullOrEmpty(password))
        {
            ShowError("Please provide both username and password.");
            return;
        }

        try
        {
            string query = "SELECT UserId, Username, FirstName, LastName, Role, SkyMiles FROM Users WHERE Username = @Username AND Password = @Password";
            SqlParameter[] parameters = new SqlParameter[]
            {
                new SqlParameter("@Username", username),
                new SqlParameter("@Password", password)
            };

            DataTable dt = DbHelper.ExecuteQuery(query, parameters);
            if (dt.Rows.Count > 0)
            {
                DataRow row = dt.Rows[0];
                int userId = Convert.ToInt32(row["UserId"]);
                string uname = row["Username"].ToString();
                string fullName = row["FirstName"].ToString() + " " + row["LastName"].ToString();
                string role = row["Role"].ToString();
                int miles = Convert.ToInt32(row["SkyMiles"]);

                // Store in Session
                UserStateHelper.SetLoggedIn(userId, uname, fullName, role, miles);

                Response.Redirect("~/User/Dashboard.aspx");
            }
            else
            {
                ShowError("Invalid User ID or Password. Please verify your credentials or register.");
            }
        }
        catch (Exception ex)
        {
            ShowError("Database error occurred: " + ex.Message);
        }
    }

    protected void btnGuestLogin_Click(object sender, EventArgs e)
    {
        UserStateHelper.SetGuest();
        Response.Redirect("~/Public/SearchFlights.aspx");
    }


    private void ShowError(string message)
    {
        pnlAlert.Visible = true;
        pnlAlert.CssClass = "alert alert-danger mb-4";
        litAlertMsg.Text = message;
    }
}

