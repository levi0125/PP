document.querySelectorAll(".desplazamiento").forEach(campo=>{
    campo.addEventListener("click",(e,target=e.target)=>{
        console.log(target)
        if(target.matches("label")){
            target.style.translate="0% 1%"
            target.style.scale=".8"
            const input = target.parentNode.querySelector("input, select");
            input?.focus(); // El ?. evita error si no existe
        // }else{
        //     target.focus()
        }
    })
    const llenable=campo.querySelector("select,input");
    llenable.addEventListener("blur",(e,target=e.target)=>{
        console.log("perdió foco")
        if(!target.matches("label") 
            && target.value==""){
            target.parentNode.children[0].style.translate="0% -100%"
            target.parentNode.children[0].style.scale="1"
        }
    })
    llenable.addEventListener("change",e=>{
        console.log("change",e.target)
    })
})


const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
        entry.target.classList.add("visible");
        // Opcional: detener la observación para que no se repita
        observer.unobserve(entry.target);
        }
    });
});

document.querySelectorAll(".scroll-reveal").forEach(el => observer.observe(el));