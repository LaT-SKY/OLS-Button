document.addEventListener("DOMContentLoaded", function() {
    const olsButtons = document.querySelectorAll(".ols-button");
    let isOnAnimate = false;
    olsButtons.forEach((olsButton) => {
        olsButton.addEventListener("click", () => {
            isOnAnimate = true;
            // 按钮变化
            olsButton.style.border = "#000 solid var(--ols-button-padding)";
            olsButton.style.setProperty("--ols-button-scale-scale","0.6");

            // 文本变化
            const text = olsButton.querySelector("span");
            text.style.transform = "translateY(10px)";
            text.style.opacity = "0";

            // SVG变化
            setTimeout(() => {
                const svg = olsButton.querySelector("svg");
                svg.style.display = "block";
                setTimeout(() => {
                    isOnAnimate = false;
                },1500)
            },300)
        })
    })
    olsButtons.forEach((olsButton) => {
        olsButton.addEventListener("mouseout", () => {
            if (isOnAnimate){return;}
            // 按钮变化
            olsButton.style.border = "none";
            olsButton.style.setProperty("--ols-button-color","#000");
            olsButton.style.setProperty("--ols-button-font-color","#fff")

            // 文本变化
            const text = olsButton.querySelector("span");
            text.style.transform = "translateY(0)";
            text.style.opacity = "1";

            // SVG变化
            const svg = olsButton.querySelector("svg");
            svg.style.display = "none";
        })
    })
    olsButtons.forEach((olsButton) => {
        olsButton.addEventListener("mouseover", () => {
            olsButton.style.setProperty("--ols-button-color","#fff");
            olsButton.style.setProperty("--ols-button-font-color","#000")
        })
    })
})