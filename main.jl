using Pkg, DataFrames, FixedEffectModels, CSV, RegressionTables, GLFixedEffectModels, GLM

df = CSV.read("Detroit.csv", DataFrame)
df_nozeros = df[df.flows .!= 0, :]

function run_regression1(df)
    return reg(df, @formula(log(flows) ~ log(distance_Google_miles) + fe(work_ID) + fe(home_ID)), Vcov.robust())
end


reg1 = run_regression1(df_nozeros)
println(reg1)

#Post compile:
@time run_regression1(df_nozeros)

regtable(
    reg1,
    title = "Regression Results",
    render = LatexTable(),
    regression_statistics = [
        Nobs => "Obs.",
        R2 => "R²",
    ],
    file = "regtable_julia1.tex"
)



function run_regression2(df)
    m = @formula flows ~ log(distance_Google_miles) + fe(work_ID) + fe(home_ID)
    return nlreg(df, m, Poisson(), LogLink())
end


reg2 = run_regression2(df)
println(reg2)

#Post compile:
@time run_regression2(df)

regtable(
    reg2,
    title = "Poisson Regression Results",
    render = LatexTable(),
    regression_statistics = [
        Nobs => "Obs.",
    ],
    file = "regtable_julia2.tex"
)

