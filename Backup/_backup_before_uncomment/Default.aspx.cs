using System;
using System.Web.UI;

public partial class _RootDefault : Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        Response.Redirect("~/Public/Home.aspx");
    }
}
