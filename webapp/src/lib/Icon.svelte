<script>
const { name, size = 1.5 } = $props()
const url = `url("/${name}.svg")`
</script>

<i
    style:width={size + 'rem'}
    style:height={size + 'rem'}
    style:mask={url + 'center / contain no-repeat'}
></i>

<style>
i {
    background-color: currentcolor;
    display: block;
}
</style>
