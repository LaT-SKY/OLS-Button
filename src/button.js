document.addEventListener("DOMContentLoaded", function() {
    const olsButtons = document.querySelectorAll(".ols-button");
    let isOnAnimate = false;
    olsButtons.forEach((olsButton) => {
        olsButton.addEventListener("click", () => {
            if (isOnAnimate) {return;}
            isOnAnimate = true;
            // 按钮变化
            olsButton.style.border = "#000 solid var(--ols-button-padding)";
            olsButton.style.setProperty("--ols-button-scale-scale","0.6");
            olsButton.style.setProperty("--ols-button-bc-color","#99c78d, #8DC5C7, #99c78d");
            olsButton.style.setProperty("--ols-button-opacity","1");

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
            if (isOnAnimate){
                olsButton.style.border = "#99c78d solid var(--ols-button-padding)";
                return;
            }
            // 按钮变化
            olsButton.style.border = "none";
            olsButton.style.setProperty("--ols-button-color","#000");
            olsButton.style.setProperty("--ols-button-font-color","#fff");
            olsButton.style.setProperty("--ols-button-opacity","0.4");

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
            if (isOnAnimate){
                olsButton.style.border = "#000 solid var(--ols-button-padding)";
                return;
            }
            olsButton.style.border = "none";
            olsButton.style.setProperty("--ols-button-color","#fff");
            olsButton.style.setProperty("--ols-button-font-color","#000")
            olsButton.style.setProperty("--ols-button-bc-color","#ff6b6b, #eeaeee, #ff6b6b");
            olsButton.style.setProperty("--ols-button-opacity","0.4");

            const text = olsButton.querySelector("span");
            text.style.transform = "translateY(0)";
            text.style.opacity = "1";

            const svg = olsButton.querySelector("svg");
            svg.style.display = "none";
        })
    })
})