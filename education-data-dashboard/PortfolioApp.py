import streamlit as st
import pandas as pd
import plotly.express as px

# ---------------- PAGE CONFIG ----------------
st.set_page_config(page_title="Education Dashboard", layout="wide")

# ---------------- CUSTOM CSS ----------------
st.markdown("""
<style>
body {
    background-color: #F7F9FC;
}
h1, h2, h3 {
    color: #1E3A8A;
}
div.block-container {
    padding-top: 2rem;
}
</style>
""", unsafe_allow_html=True)

# ---------------- LOAD DATA ----------------
@st.cache_data
def load_data():
    return pd.read_csv("data/wb_education_featured.csv")  

df = load_data()

# ---------------- SIDEBAR ----------------
st.sidebar.header("🎛️ Filters")

year = st.sidebar.selectbox(
    "Select Year",
    sorted(df["Year"].unique()),
    key="year_filter"
)

district = st.sidebar.multiselect(
    "Select District",
    df["District"].unique(),
    key="district_filter"
)

# ---------------- FILTER ----------------
filtered = df[df["Year"] == year]

if district:
    filtered = filtered[filtered["District"].isin(district)]

# ---------------- TITLE ----------------
st.title("📊 West Bengal Education Dashboard")
st.caption("Interactive analysis using Python, Streamlit & Data Analytics")

# ---------------- TABS ----------------
tab1, tab2, tab3 = st.tabs(["📊 Overview", "🔍 Deep Analysis", "📈 Insights"])

# ================= TAB 1 =================
with tab1:
    st.subheader("📊 Overview")

    col1, col2, col3, col4 = st.columns(4)

    col1.metric("Avg Performance", round(filtered["Performance_Index"].mean(), 2))
    col2.metric("Avg Retention", round(filtered["Retention_Rate"].mean(), 2))
    col3.metric("Avg Madhyamik", round(filtered["Madhyamik_Pass_Percentage"].mean(), 2))
    col4.metric("Avg HS", round(filtered["HS_Pass_Percentage"].mean(), 2))

    st.markdown("---")

    trend = df.groupby("Year")["Performance_Index"].mean().reset_index()

    fig1 = px.line(trend, x="Year", y="Performance_Index", markers=True)
    fig1.update_traces(line_color="#1E3A8A")

    st.plotly_chart(fig1, use_container_width=True)

# ================= TAB 2 =================
with tab2:
    st.subheader("🔍 Deep Analysis")

    fig2 = px.scatter(
        filtered,
        x="Retention_Rate",
        y="Performance_Index",
        hover_name="District",
        size="Total",
        color="Performance_Index"
    )
    st.plotly_chart(fig2, use_container_width=True)

    filtered_copy = filtered.copy()
    filtered_copy["Gap"] = (
        filtered_copy["HS_Pass_Percentage"] - 
        filtered_copy["Madhyamik_Pass_Percentage"]
    )

    fig3 = px.bar(
        filtered_copy.sort_values("Gap", ascending=False),
        x="Gap",
        y="District",
        orientation="h",
        color="Gap"
    )
    st.plotly_chart(fig3, use_container_width=True)

    csv = filtered_copy.to_csv(index=False).encode('utf-8')

    st.download_button(
        "📥 Download Filtered Data",
        csv,
        "filtered_data.csv",
        "text/csv"
    )

# ================= TAB 3 =================
with tab3:
    st.subheader("📈 Insights")

    st.markdown("""
    ### 🔍 Key Observations:

    - Overall performance improved steadily from 2018 to 2020  
    - Districts with higher retention show better performance  
    - HS vs Madhyamik gap highlights improvement opportunities  

    ### 📌 Conclusion:

    - Retention rate is a key performance driver  
    - Focus on low-performing districts can improve outcomes  
    """)