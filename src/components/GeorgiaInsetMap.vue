<template>
  <div id="insetMap">
    <picture>
      <source
        srcset="@/assets/images/inset/insetGeorgiaLarge.webp"
        type="image/webp"
      >
      <source
        srcset="@/assets/images/inset/insetGeorgiaLarge.png"
        type="image/png"
      >
      <source
        srcset="@/assets/images/inset/insetGeorgiaMedium.png"
        type="image/png"
      >
      <img 
        src="@/assets/images/inset/insetGeorgiaSmall.png" 
        alt="The state of Georgia Highlighting the City of Atlanta"
        draggable="false"
        ondragstart="return false;"
      >
    </picture>
  </div>
</template>
<script setup>
</script>
<style scoped lang="scss">
    #insetMap{
        width: 20%;
        height: 20%;
        position: absolute;
        left: 5px;
        bottom: 5px;
        z-index: 90000;
        object-fit: 'contain';
        img{
          width: 100%;
          height: 100%;
          -webkit-user-select: none; /* Safari, Chrome */
          -khtml-user-select: none; /* Konqueror */
          -moz-user-select: none; /* Firefox */
          -ms-user-select: none; /* IE */
          user-select: none; /* CSS3 */
        }
    }
    @media screen and (min-width: 600px){
      #insetMap{
        left: 10px;
        bottom: 10px;
      }
    }
</style>
