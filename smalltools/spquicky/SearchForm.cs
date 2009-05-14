using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
using System.Diagnostics;

namespace SqlObjectSearch
{
    public partial class SearchForm : Form
    {
        ObjectSearch objectSearch = new ObjectSearch();
        StoreProcView sp = null;
        public SearchForm()
        {
            InitializeComponent();
            this.dataGridView1.ReadOnly = true;
            this.dataGridView1.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
            this.Text = "StoreProc Finder";
            label4.Text = "Total";
            label3.Text = "0";
            this.txtDatabase.Text = "data source=.;initial catalog=master;user id=sa;password=";
            button1.Text = "...";
            button1.Enabled = true;
            this.dataGridView1.AutoGenerateColumns = false;
            DataGridViewColumn col = new DataGridViewTextBoxColumn();
            col.DataPropertyName = "ObjectName";
            col.HeaderText = "ObjectName";
            col.Width = 300;
            this.dataGridView1.Columns.Add(col);
                
        }

        private void btnFind_Click(object sender, EventArgs e)
        {
            try
            {
                txtDatabase.Text = txtDatabase.Text.Replace("Provider=SQLOLEDB.1;", "");
                sp = new StoreProcView(txtDatabase.Text);
                objectSearch.ObjectTypes = 8;
                objectSearch.SearchKey = string.Format("%{0}%",txtSearchKey.Text.Trim());
                objectSearch.ConnStr = this.txtDatabase.Text;
                objectSearch.PerformSearch();
                this.dataGridView1.DataSource = objectSearch.Results;
                label3.Text = objectSearch.Results.Count.ToString();
                btnStop.Enabled = objectSearch.Results.Count>0 ;
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, Application.ProductName, MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void dataGridView1_CellContentDoubleClick(object sender, DataGridViewCellEventArgs e)
        {
       
        }

        private void dataGridView1_CellDoubleClick(object sender, DataGridViewCellEventArgs e)
        {
            Run(e.RowIndex);
        }

        private void Run(int rowIndex)
        {
            if (rowIndex != -1)
            {
                SearchHit hit = (SearchHit)this.dataGridView1.Rows[rowIndex].DataBoundItem;
                if (hit != null)
                {
                    sp.Run(hit.objectName);
                }
            }
        }
        private string PromptDataSource()
        {
            // refernce these :在.net标签内 Microsoft ActiveX Data Objects 2.8 Library (=ADODB namespace)
            // 在com标签内 the Microsoft OLE DB Service Component 1.0 Type Library (=MSDASC namespace).
            MSDASC.DataLinks dataLinks = new MSDASC.DataLinksClass();
            ADODB.Connection connection = new ADODB.ConnectionClass();
            object oConnection = (object)connection;
            if (dataLinks.PromptEdit(ref oConnection))
                return connection.ConnectionString;
            else
                return "";
        }
        private void button1_Click(object sender, EventArgs e)
        {
            //
            this.txtDatabase.Text =  PromptDataSource();
        }

        private void btnStop_Click(object sender, EventArgs e)
        {
            Run(this.dataGridView1.SelectedRows[0].Index);
        }

        
    }
}