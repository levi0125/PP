
document.querySelectorAll(".btn-dinamico").forEach(boton=>{
    boton.addEventListener("click",e=>location.replace(e.target.dataset['href']))
})